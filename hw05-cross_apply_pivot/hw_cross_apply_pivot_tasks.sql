/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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

--set statistics io, time on


/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

select 
	format(cast(concat('01.',InvoiceDate) as date), 'd', 'de-de') as inDate, 
	[Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Sylvanite, MT], [Jessie, ND]
from (
	select 
		InvoiceDate, 
		max(replace(STUFF(cross1.CustomerName, 1, charindex('(', cross1.CustomerName), ''), ')', '')) as customer, 
		count(InvoiceID) as count_purchase
	from (
			select 
				InvoiceID, 
				CustomerID, 
				substring(cast(format(InvoiceDate, 'd', 'de-de') as nvarchar), 4,10) as InvoiceDate 
			from [Sales].[Invoices] 
			where CustomerID between 2 and 6
		) as Invoices
	cross apply(
				select CustomerName
				from [Sales].[Customers] c
				where c.CustomerID = Invoices.CustomerID
	) cross1
	group by Invoices.CustomerID, InvoiceDate
	) t1
pivot(
		max(count_purchase) for customer in ([Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND])
) piv
order by cast(concat('01.',InvoiceDate) as date)

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

select CustomerName, columnValues as AddressLine
from [Sales].[Customers]
unpivot(
		columnValues FOR columnNames IN (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)
) unpiv
where CustomerName like '%Tailspin Toys%'

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select  CountryId, CountryName, columnValues
from ( select CountryId, CountryName, IsoAlpha3Code, cast(IsoNumericCode as nvarchar(3)) as IsoNumericCode from [Application].[Countries]) as [Countries]
unpivot(
		columnValues FOR columnNames IN (IsoAlpha3Code, IsoNumericCode)
) unpiv


/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select c.CustomerID, c.CustomerName, cross1.*
from [Sales].[Customers] c
cross apply(
			select top 2 il.StockItemID, il.UnitPrice, i.InvoiceDate
			from [Sales].[InvoiceLines] il
			join [Sales].[Invoices] i on i.InvoiceID = il.InvoiceID
			where i.CustomerID = c.CustomerID
			order by il.UnitPrice desc
) cross1
