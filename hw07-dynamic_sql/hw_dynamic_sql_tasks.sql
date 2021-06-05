/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

declare @sql nvarchar(max)
declare @columns nvarchar(max)
 
select @columns = isnull(@columns + ',', '') + QUOTENAME(CustomerName)
from (
	select distinct
		CustomerName
	from [Sales].[Invoices] i
	join [Sales].[Customers] c on c.CustomerID = i.CustomerID
	) t
order by CustomerName

set @sql = 
	N'select 
		format(cast(concat(''01.'',InvoiceDate) as date), ''d'', ''de-de'') as inDate, '
		+ @columns +
	'from (
		select 
			InvoiceDate, 
			max(CustomerName) as customer, 
			count(InvoiceID) as count_purchase
		from (
				select 
					InvoiceID, 
					i.CustomerID, 
					CustomerName,
					substring(cast(format(InvoiceDate, ''d'', ''de-de'') as nvarchar), 4,7) as InvoiceDate 
				from [Sales].[Invoices] i
				join [Sales].[Customers] c on c.CustomerID = i.CustomerID
			) as Invoices
		group by Invoices.CustomerID, InvoiceDate
		) t1
	pivot(
			max(count_purchase) for customer in (' + @columns +')
	) piv
	order by cast(concat(''01.'',InvoiceDate) as date)'

exec sp_executesql @sql

