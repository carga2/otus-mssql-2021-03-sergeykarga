/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select StockItemID, StockItemName
from Warehouse.StockItems
where StockItemName like '%urgent%' or StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select sup.SupplierID, SupplierName
from Purchasing.Suppliers sup
left join Purchasing.PurchaseOrders orders on orders.SupplierID = sup.SupplierID
where orders.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select 
	o.OrderID, 
	convert(nvarchar, o.OrderDate, 104) as [Дата],
	DATENAME(month, o.OrderDate) as [Месяц],
	DATENAME(quarter, o.OrderDate) as [Квартал],
	CASE 
		WHEN (MONTH(o.OrderDate) <= 4) THEN 1
		WHEN (MONTH(o.OrderDate) <= 8) THEN 2
		ELSE 3
	END as [Треть года],
	l.OrderLineID, 
	l.UnitPrice, 
	l.Quantity, 
	c.CustomerName
from Sales.Orders o
join Sales.OrderLines l on l.OrderID = o.OrderID 
	and	l.PickingCompletedWhen  is not null 
	and (l.UnitPrice > 100  or l.Quantity > 20)
join Sales.Customers c on c.CustomerID = o.CustomerID

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select 
	d.DeliveryMethodName, 
	o.ExpectedDeliveryDate, 
	s.SupplierName, 
	p.FullName
from Purchasing.PurchaseOrders o
join Purchasing.Suppliers s on o.SupplierID = s.SupplierID 
join Application.DeliveryMethods d on d.DeliveryMethodID = o.DeliveryMethodID and d.DeliveryMethodName in ( 'Air Freight', 'Refrigerated Air Freight')
join Application.People p on p.PersonID = o.ContactPersonID
where datepart(year, o.ExpectedDeliveryDate) = 2013 and datepart(month, o.ExpectedDeliveryDate) = 1 and o.IsOrderFinalized = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10 
	c.CustomerName, 
	p.FullName
from [Sales].[Orders] o
join [Sales].[Customers] c on c.CustomerID = o.CustomerID
join [Application].[People] p on p.PersonID = o.SalespersonPersonID
order by o.OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select 
	o.CustomerID
	,c.CustomerName
	,c.PhoneNumber
from [Sales].[Orders] o
join [Sales].[OrderLines] l on l.OrderID = o.OrderID
join [Warehouse].[StockItems] s on s.StockItemID = l.StockItemID
join [Sales].[Customers] c on o.CustomerID = c.CustomerID
where s.StockItemName = 'Chocolate frogs 250g'

/*
7. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select
	YEAR(i.InvoiceDate) as [year]
	,MONTH(i.InvoiceDate) as [month]
	,avg(l.UnitPrice) as [avg]
	,sum(l.UnitPrice) as total
from [Sales].[Invoices] i
join [Sales].[InvoiceLines] l on l.InvoiceID = i.InvoiceID
group by YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
order by [year], [month]

/*
8. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select
	YEAR(i.InvoiceDate) as [year]
	,MONTH(i.InvoiceDate) as [month]
	,sum(l.UnitPrice) as total
from [Sales].[Invoices] i
join [Sales].[InvoiceLines] l on l.InvoiceID = i.InvoiceID
group by YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
having sum(l.UnitPrice) > 10000
order by [year], [month]

/*
9. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select
	YEAR(i.InvoiceDate) as [year]
	,MONTH(i.InvoiceDate) as [month]
	,s.StockItemName
	,sum(l.UnitPrice) as total
	,min(i.InvoiceDate) as firstDate
	,sum(l.Quantity) as [count]
from [Sales].[Invoices] i
join [Sales].[InvoiceLines] l on l.InvoiceID = i.InvoiceID
join [Warehouse].[StockItems] s on s.StockItemID = l.StockItemID
group by YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), s.StockItemName
having sum(l.Quantity) < 50
order by [year], [month]

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 8-9 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

-- Задание 9
select
	YEAR(i.InvoiceDate) as [year]
	,MONTH(i.InvoiceDate) as [month]
	,t.StockItemName
	,t.total
	,t.firstDate
	,t.count
from [Sales].[Invoices] i
left join (
			select
				YEAR(i.InvoiceDate) as [year]
				,MONTH(i.InvoiceDate) as [month]
				,s.StockItemName
				,sum(l.UnitPrice) as total
				,min(i.InvoiceDate) as firstDate
				,sum(l.Quantity) as [count]
			from [Sales].[Invoices] i
			join [Sales].[InvoiceLines] l on l.InvoiceID = i.InvoiceID
			join [Warehouse].[StockItems] s on s.StockItemID = l.StockItemID
			group by YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), s.StockItemName
			having sum(l.Quantity) < 50
		  ) t on t.year = YEAR(i.InvoiceDate) and t.month = MONTH(i.InvoiceDate)
group by YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), t.StockItemName, t.total, t.firstDate, t.count
order by [year], [month]
