/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, GROUP BY, HAVING".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/

select StockItemID, StockItemName
from Warehouse.StockItems
where StockItemName like '%urgent%' or StockItemName like 'Animal%'

/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.
�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/

select sup.SupplierID, SupplierName
from Purchasing.Suppliers sup
left join Purchasing.PurchaseOrders orders on orders.SupplierID = sup.SupplierID
where orders.SupplierID is null

/*
3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.����
* �������� ������, � ������� ��� ������ �����
* ����� ��������, � ������� ��� ������ �����
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.

���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).

�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select 
	o.OrderID, 
	convert(nvarchar, o.OrderDate, 104) as [����],
	DATENAME(month, o.OrderDate) as [�����],
	DATENAME(quarter, o.OrderDate) as [�������],
	CASE 
		WHEN (MONTH(o.OrderDate) <= 4) THEN 1
		WHEN (MONTH(o.OrderDate) <= 8) THEN 2
		ELSE 3
	END as [����� ����],
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
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).
�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)

�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
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
5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.
*/

select top 10 
	c.CustomerName, 
	p.FullName
from [Sales].[Orders] o
join [Sales].[Customers] c on c.CustomerID = o.CustomerID
join [Application].[People] p on p.PersonID = o.SalespersonPersonID
order by o.OrderDate desc

/*
6. ��� �� � ����� �������� � �� ���������� ��������,
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems.
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
7. ��������� ������� ���� ������, ����� ����� ������� �� �������
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����

������� �������� � ������� Sales.Invoices � ��������� ��������.
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
8. ���������� ��� ������, ��� ����� ����� ������ ��������� 10 000

�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ����� ����� ������

������� �������� � ������� Sales.Invoices � ��������� ��������.
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
9. ������� ����� ������, ���� ������ �������
� ���������� ���������� �� �������, �� �������,
������� ������� ����� 50 �� � �����.
����������� ������ ���� �� ����,  ������, ������.

�������:
* ��� �������
* ����� �������
* ������������ ������
* ����� ������
* ���� ������ �������
* ���������� ����������

������� �������� � ������� Sales.Invoices � ��������� ��������.
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
-- �����������
-- ---------------------------------------------------------------------------
/*
�������� ������� 8-9 ���, ����� ���� � �����-�� ������ �� ���� ������,
�� ���� ����� ����� ����������� �� � �����������, �� ��� ���� ����.
*/

-- ������� 9
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
