/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

select p.PersonID, p.FullName
from Application.People p
where p.PersonID in (select SalespersonPersonID
					from Sales.Invoices
					where InvoiceDate <> '20150704')

;with cte as
(
	select p.PersonID, p.FullName
	from Application.People p
	where p.PersonID in (select SalespersonPersonID
					from Sales.Invoices
					where InvoiceDate <> '20150704')
)
select * from cte

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

select s.StockItemID, s.StockItemName, s.UnitPrice
from [Warehouse].[StockItems] s
where s.UnitPrice = (select min(UnitPrice) from [Warehouse].[StockItems])

select s.StockItemID, s.StockItemName, s.UnitPrice
from [Warehouse].[StockItems] s
where s.UnitPrice <= all (select UnitPrice from [Warehouse].[StockItems])

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

select top 5 *
from Sales.CustomerTransactions
order by TransactionAmount desc

;with cte as
(
	select *
	from Sales.CustomerTransactions
	order by TransactionAmount desc OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY
)
select * from cte

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

select distinct 
	cities.CityID, 
	cities.CityName, 
	(select FullName from [Application].[People] where PersonID = i.PackedByPersonID) as FullName,
	si.UnitPrice
from [Sales].[Invoices] i
join [Sales].[InvoiceLines] il on il.InvoiceID = i.InvoiceID
join (select top 3 StockItemID, UnitPrice from [Warehouse].[StockItems] order by UnitPrice desc) si on si.StockItemID = il.StockItemID
join [Sales].[Customers] c on c.CustomerID = i.CustomerID
join [Application].[Cities] cities on cities.CityID = c.DeliveryCityID
where i.ConfirmedReceivedBy is not null
order by cities.CityName, FullName

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос
SET STATISTICS IO, TIME ON

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

select 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate
	,People.FullName AS SalesPersonName,
	SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice) AS TotalSummForPickedItems,
	SalesTotals.TotalSumm
from (
	SELECT
	InvoiceLines.InvoiceId,
	SUM(InvoiceLines.Quantity * InvoiceLines.UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceLines.InvoiceId
	HAVING SUM(InvoiceLines.Quantity * InvoiceLines.UnitPrice) > 27000
	) SalesTotals
join Sales.Invoices ON Invoices.InvoiceID = SalesTotals.InvoiceID
join Application.People on People.PersonID = Invoices.SalespersonPersonID
join Sales.Orders on Orders.OrderId = Invoices.OrderId and Orders.PickingCompletedWhen IS NOT NULL
join Sales.OrderLines on OrderLines.OrderId = Orders.OrderId 
group by Invoices.InvoiceID, Invoices.InvoiceDate, People.FullName, SalesTotals.TotalSumm
ORDER BY TotalSumm DESC


-- запрос выдает ид, дату продажи, продавца, сумму продажи, сумму уже скомплектованного
-- сумма продажи у которых больше 27000 и заказы уже начали комплектоваться