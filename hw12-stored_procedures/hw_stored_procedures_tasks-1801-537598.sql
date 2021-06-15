/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

create function lesson12_f1()
RETURNS nvarchar(100)  
WITH EXECUTE AS CALLER  
AS  
BEGIN  
     DECLARE @maxClient nvarchar(100);  
      
	 select distinct
		@maxClient = c.CustomerName
	 from (
		  select 
			CustomerID
			,UnitPrice
			,max(UnitPrice) over () as max_sum
		  from (
			  select 
				i.InvoiceID
				,i.CustomerID
				,sum(il.UnitPrice) over (partition by i.InvoiceID) as UnitPrice
			  from [Sales].[InvoiceLines] il
			  join [Sales].[Invoices] i on i.InvoiceID = il.InvoiceID
			) t
		) s
	join [Sales].[Customers] c on c.CustomerID = s.CustomerID
	 where UnitPrice = max_sum

     RETURN(@maxClient);  
END;  
GO  

declare @maxClient nvarchar(100) 
select @maxClient= dbo.lesson12_f1()
select @maxClient

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

create procedure lesson12_sp2
(
	@CustomerID int
)
WITH EXECUTE AS CALLER
AS  
    SET NOCOUNT ON;  

    select 
		sum(il.UnitPrice) as UnitPrice
	from [Sales].[InvoiceLines] il
	join [Sales].[Invoices] i on i.InvoiceID = il.InvoiceID
	join [Sales].[Customers] c on c.CustomerID = i.CustomerID
	where i.CustomerID = @CustomerID  
GO 

exec dbo.lesson12_sp2 13

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

create function lesson12_f3
(
	@CustomerID int
)
RETURNS numeric(10,2) 
WITH EXECUTE AS CALLER  
AS  
BEGIN  
     DECLARE @sum numeric(10,2);  
      
	 select 
		@sum= sum(il.UnitPrice)
	from [Sales].[InvoiceLines] il
	join [Sales].[Invoices] i on i.InvoiceID = il.InvoiceID
	join [Sales].[Customers] c on c.CustomerID = i.CustomerID
	where i.CustomerID = @CustomerID  

     RETURN(@sum);  
END;  
GO  

declare @clientSum numeric(10,2) 
select @clientSum= dbo.lesson12_f3(13)
select @clientSum

exec dbo.lesson12_sp2 13

/*
 Время работы SQL Server:
   Время ЦП = 16 мс, затраченное время = 21 мс.

(1 row affected)

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 10 мс, истекшее время = 10 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Customers". Число просмотров 0, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "InvoiceLines". Число просмотров 86, логических чтений 1034, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Invoices". Число просмотров 1, логических чтений 3, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 1 мс.

 Время работы SQL Server:
   Время ЦП = 15 мс, затраченное время = 11 мс.

Completion time: 2021-06-12T11:46:15.8955290+04:00
*/


/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

CREATE FUNCTION lesson12_f4 
(
	@CustomerID int
)  
RETURNS TABLE  
AS  
RETURN   
(  
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
	  where c.CustomerID = @CustomerID
	  )t
	where CustomerTransRank < 3
	group by CustomerID, CustomerName, [StockItemID], [UnitPrice]
);  
GO    

select 
	c.CustomerID, c.CustomerName, UnitPrice, StockItemID, InvoiceDate
from [Sales].[Customers] c
cross apply lesson12_f4(c.CustomerID)

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/

Read uncommitted во всех случаях