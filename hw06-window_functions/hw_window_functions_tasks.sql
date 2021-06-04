/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

select 
	t.InvoiceID, 
	t.CustomerName, 
	t.InvoiceDate, 
	t.sum_invoice,
	sum(sum_month) as total
from(
select 
	i.InvoiceID, 
	c.CustomerName, 
	i.InvoiceDate, 
	sum(il.UnitPrice) as sum_invoice
from [Sales].[Invoices] i
join [Sales].[InvoiceLines] il on il.InvoiceID = i.InvoiceID
join [Sales].[Customers] c on c.CustomerID = i.CustomerID
where i.InvoiceDate >= '20150101'
group by i.InvoiceID, c.CustomerName, i.InvoiceDate
) t
join 	(
		select concat(year(i2.InvoiceDate), RIGHT('00'+Convert(Varchar(2), month(i2.InvoiceDate)),2), '01') dt, sum(il2.UnitPrice) as sum_month
		from [Sales].[Invoices] i2
		join [Sales].[InvoiceLines] il2 on il2.InvoiceID = i2.InvoiceID
		where i2.InvoiceDate >= '20150101'
		group by concat(year(i2.InvoiceDate), RIGHT('00'+Convert(Varchar(2), month(i2.InvoiceDate)),2), '01')
) as total_month on total_month.dt <= t.InvoiceDate
group by t.InvoiceID, t.CustomerName, t.InvoiceDate,t.sum_invoice
order by t.InvoiceDate

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io off
*/

select 
	t.InvoiceID, 
	t.CustomerName, 
	t.InvoiceDate, 
	t.sum_invoice,
	SUM(t.sum_invoice) OVER(ORDER BY year(t.InvoiceDate),  month(t.InvoiceDate)) AS RunningTotal
from(
select 
	i.InvoiceID, 
	c.CustomerName, 
	i.InvoiceDate, 
	sum(il.UnitPrice) as sum_invoice
from [Sales].[Invoices] i
join [Sales].[InvoiceLines] il on il.InvoiceID = i.InvoiceID
join [Sales].[Customers] c on c.CustomerID = i.CustomerID
where i.InvoiceDate >= '20150101'
group by i.InvoiceID, c.CustomerName, i.InvoiceDate
) t


/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

select distinct
	DATENAME(month, t1.InvoiceDate) as month_name, nm as month_number,
	t1.StockItemID
	from(
			select 
				t.InvoiceDate, MONTH(InvoiceDate) nm,
				t.StockItemID, sum_cust_month
				,DENSE_RANK() OVER (PARTITION BY  month(t.InvoiceDate) ORDER BY t.InvoiceDate, sum_cust_month desc, t.StockItemID) AS CustomerTransRank
			from (
					select
						i.InvoiceDate, il.StockItemID
						, count(il.StockItemID) OVER (PARTITION BY il.StockItemID, month(i.InvoiceDate)) as sum_cust_month
					from [Sales].[Invoices] i
					join [Sales].[InvoiceLines] il on il.InvoiceID = i.InvoiceID
					where i.InvoiceDate >= '20160101'
			) t
		) t1
where CustomerTransRank <=2
order by month_number

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select 
	[StockItemID]
	,[StockItemName]
	,[Brand]
	,[UnitPrice]
	,DENSE_RANK() OVER (PARTITION BY  left([StockItemName], 1) ORDER BY [StockItemName]) as first_alfa
	,count([StockItemName]) over () as total_count
	,count([StockItemName]) over (PARTITION BY  left([StockItemName], 1)) as first_alfa_count
	,LEAD([StockItemID]) OVER (ORDER BY [StockItemName]) as next_item 
	,lag([StockItemID]) OVER (ORDER BY [StockItemName]) as prev_item 
	,lag([StockItemName], 2, 'No items') OVER (ORDER BY [StockItemName]) as prev_item2
	,ntile(30) OVER (ORDER BY [TypicalWeightPerUnit]) as ntile_20
from [Warehouse].[StockItems]

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

select 
	p.PersonID, p.FullName
	,c.CustomerID, c.CustomerName
	,max(i.InvoiceDate) as InvoiceDate
	,sum(il.[UnitPrice]) as sum_deal
from (
		select
			i.SalespersonPersonID
			,max(i.CustomerID) as CustomerID
			,max(i.InvoiceID) as InvoiceID
			,max(i.InvoiceDate) as InvoiceDate
		from [Sales].[Invoices] i
		group by i.SalespersonPersonID
	) i
join [Sales].[InvoiceLines] il on il.InvoiceID = i.InvoiceID
join [Application].[People] p on p.[PersonID] = i.SalespersonPersonID
join [Sales].[Customers] c on c.CustomerID = i.CustomerID
group by p.PersonID, p.FullName, c.CustomerID, c.CustomerName
order by p.PersonID, p.FullName

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select
	CustomerID
	,CustomerName
	,[StockItemID]
	,[UnitPrice]
	,max(InvoiceDate) as InvoiceDate
from (
SELECT  [InvoiceLineID]
      ,il.[InvoiceID]
      ,[StockItemID]
      ,[UnitPrice]
	  ,i.CustomerID
	  ,c.CustomerName
	  ,i.InvoiceDate
	  ,DENSE_RANK() OVER (PARTITION BY i.CustomerID ORDER BY [UnitPrice] DESC, [StockItemID]) AS CustomerTransRank
  FROM [WideWorldImporters].[Sales].[InvoiceLines] il
  join [Sales].[Invoices] i on i.InvoiceID = il.InvoiceID
  join [Sales].[Customers] c on c.CustomerID = i.CustomerID
  )t
where CustomerTransRank < 3
group by CustomerID, CustomerName, [StockItemID], [UnitPrice]
order by CustomerID

Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 