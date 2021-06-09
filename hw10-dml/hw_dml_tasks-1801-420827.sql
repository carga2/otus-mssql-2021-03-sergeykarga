/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

INSERT [Sales].[Customers] ([CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID], [PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID], [CreditLimit], [AccountOpenedDate], [StandardDiscountPercentage], [IsStatementSent], [IsOnCreditHold], [PaymentDays], [PhoneNumber], [FaxNumber], [DeliveryRun], [RunPosition], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode], [LastEditedBy], [ValidFrom], [ValidTo]) 
VALUES (1062, N'Семен Буденый', 1, 3, 1, 1001, 1002, 3, 19586, 19586, NULL, CAST(N'2013-01-01' AS Date), CAST(0.000 AS Decimal(18, 3)), 0, 0, 7, N'(308) 555-0100', N'(308) 555-0101', N'', N'', N'http://www.tailspintoys.com', N'Shop 38', N'1877 Mittal Road', N'90410', 0xE6100000010CE73F5A52A4BF444010638852B1A759C0, N'PO Box 8975', N'Ribeiroville', N'90410', 1, default, default)
INSERT [Sales].[Customers] ([CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID], [PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID], [CreditLimit], [AccountOpenedDate], [StandardDiscountPercentage], [IsStatementSent], [IsOnCreditHold], [PaymentDays], [PhoneNumber], [FaxNumber], [DeliveryRun], [RunPosition], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode], [LastEditedBy], [ValidFrom], [ValidTo]) 
VALUES (1063, N'Александр Матросов', 1, 3, 1, 1001, 1002, 3, 19586, 19586, NULL, CAST(N'2013-01-01' AS Date), CAST(0.000 AS Decimal(18, 3)), 0, 0, 7, N'(308) 555-0100', N'(308) 555-0101', N'', N'', N'http://www.tailspintoys.com', N'Shop 38', N'1877 Mittal Road', N'90410', 0xE6100000010CE73F5A52A4BF444010638852B1A759C0, N'PO Box 8975', N'Ribeiroville', N'90410', 1, default, default)
INSERT [Sales].[Customers] ([CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID], [PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID], [CreditLimit], [AccountOpenedDate], [StandardDiscountPercentage], [IsStatementSent], [IsOnCreditHold], [PaymentDays], [PhoneNumber], [FaxNumber], [DeliveryRun], [RunPosition], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode], [LastEditedBy], [ValidFrom], [ValidTo]) 
VALUES (1064, N'Федор Ушаков', 1, 3, 1, 1001, 1002, 3, 19586, 19586, NULL, CAST(N'2013-01-01' AS Date), CAST(0.000 AS Decimal(18, 3)), 0, 0, 7, N'(308) 555-0100', N'(308) 555-0101', N'', N'', N'http://www.tailspintoys.com', N'Shop 38', N'1877 Mittal Road', N'90410', 0xE6100000010CE73F5A52A4BF444010638852B1A759C0, N'PO Box 8975', N'Ribeiroville', N'90410', 1, default, default)
INSERT [Sales].[Customers] ([CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID], [PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID], [CreditLimit], [AccountOpenedDate], [StandardDiscountPercentage], [IsStatementSent], [IsOnCreditHold], [PaymentDays], [PhoneNumber], [FaxNumber], [DeliveryRun], [RunPosition], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode], [LastEditedBy], [ValidFrom], [ValidTo]) 
VALUES (1065, N'Александр Невский', 1, 3, 1, 1001, 1002, 3, 19586, 19586, NULL, CAST(N'2013-01-01' AS Date), CAST(0.000 AS Decimal(18, 3)), 0, 0, 7, N'(308) 555-0100', N'(308) 555-0101', N'', N'', N'http://www.tailspintoys.com', N'Shop 38', N'1877 Mittal Road', N'90410', 0xE6100000010CE73F5A52A4BF444010638852B1A759C0, N'PO Box 8975', N'Ribeiroville', N'90410', 1, default, default)
INSERT [Sales].[Customers] ([CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID], [PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID], [CreditLimit], [AccountOpenedDate], [StandardDiscountPercentage], [IsStatementSent], [IsOnCreditHold], [PaymentDays], [PhoneNumber], [FaxNumber], [DeliveryRun], [RunPosition], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode], [LastEditedBy], [ValidFrom], [ValidTo]) 
VALUES (1066, N'Александр Покрышкин', 1, 3, 1, 1001, 1002, 3, 19586, 19586, NULL, CAST(N'2013-01-01' AS Date), CAST(0.000 AS Decimal(18, 3)), 0, 0, 7, N'(308) 555-0100', N'(308) 555-0101', N'', N'', N'http://www.tailspintoys.com', N'Shop 38', N'1877 Mittal Road', N'90410', 0xE6100000010CE73F5A52A4BF444010638852B1A759C0, N'PO Box 8975', N'Ribeiroville', N'90410', 1, default, default)


/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

delete from [Sales].[Customers] where [CustomerID] = 1062

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update [Sales].[Customers]
set [CustomerName] = N'Иван Кожедуб'
where [CustomerID] = 1063

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE [Sales].[Customers] AS target
USING (
		select *
		from (values(1066, N'Александр Суворов', 1, 3, 1, 1001, 1002, 3, 19586, 19586, NULL, CAST(N'2013-01-01' AS Date), CAST(0.000 AS Decimal(18, 3)), 0, 0, 7, N'(308) 555-0100', N'(308) 555-0101', N'', N'', N'http://www.tailspintoys.com', N'Shop 38', N'1877 Mittal Road', N'90410', 0xE6100000010CE73F5A52A4BF444010638852B1A759C0, N'PO Box 8975', N'Ribeiroville', N'90410', 1, cast('2021-06-09 18:10:52.8396650' as datetime2), cast('9999-12-31 23:59:59.9999999' as datetime2))
					,(1067, N'Иосиф Сталин', 1, 3, 1, 1001, 1002, 3, 19586, 19586, NULL, CAST(N'2013-01-01' AS Date), CAST(0.000 AS Decimal(18, 3)), 0, 0, 7, N'(308) 555-0100', N'(308) 555-0101', N'', N'', N'http://www.tailspintoys.com', N'Shop 38', N'1877 Mittal Road', N'90410', 0xE6100000010CE73F5A52A4BF444010638852B1A759C0, N'PO Box 8975', N'Ribeiroville', N'90410', 1, cast('2021-06-09 18:10:52.8396650' as datetime2), cast('9999-12-31 23:59:59.9999999' as datetime2))
				) AS X([CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID], [PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID], [CreditLimit], [AccountOpenedDate], [StandardDiscountPercentage], [IsStatementSent], [IsOnCreditHold], [PaymentDays], [PhoneNumber], [FaxNumber], [DeliveryRun], [RunPosition], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode], [LastEditedBy], [ValidFrom], [ValidTo])
      ) AS source([CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID], [PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID], [CreditLimit], [AccountOpenedDate], [StandardDiscountPercentage], [IsStatementSent], [IsOnCreditHold], [PaymentDays], [PhoneNumber], [FaxNumber], [DeliveryRun], [RunPosition], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode], [LastEditedBy], [ValidFrom], [ValidTo]) 
ON (target.[CustomerID] = source.[CustomerID]) 
WHEN MATCHED THEN 
	UPDATE 
	SET 
		target.[CustomerID]	= source.[CustomerID]

WHEN NOT MATCHED THEN 
	INSERT (
			[CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID], [PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID], [CreditLimit], [AccountOpenedDate], [StandardDiscountPercentage], [IsStatementSent], [IsOnCreditHold], [PaymentDays], [PhoneNumber], [FaxNumber], [DeliveryRun], [RunPosition], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode], [LastEditedBy], [ValidFrom], [ValidTo]
			)
	VALUES	(
				source.[CustomerID], [CustomerName], source.[BillToCustomerID], source.[CustomerCategoryID], source.[BuyingGroupID], source.[PrimaryContactPersonID], source.[AlternateContactPersonID], source.[DeliveryMethodID], source.[DeliveryCityID], source.[PostalCityID], source.[CreditLimit], source.[AccountOpenedDate], source.[StandardDiscountPercentage], source.[IsStatementSent], source.[IsOnCreditHold], source.[PaymentDays], source.[PhoneNumber], source.[FaxNumber], source.[DeliveryRun], source.[RunPosition], source.[WebsiteURL], source.[DeliveryAddressLine1], source.[DeliveryAddressLine2], source.[DeliveryPostalCode], source.[DeliveryLocation], source.[PostalAddressLine1], source.[PostalAddressLine2], source.[PostalPostalCode], source.[LastEditedBy], default, default
			)
OUTPUT $action, inserted.*, deleted.*; 


/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/
exec master..xp_cmdshell 'BCP [WideWorldImporters].[Sales].[Customers] OUT D:\Customers.csv -T -c'

-- Не смог проверить, т.к. установлен MSSQLServer2016
BULK INSERT [WideWorldImporters].[Sales].[Customers2]
   FROM 'D:\Customers.csv'
   WITH
      (  FORMAT = 'CSV'
         , FIELDTERMINATOR ='\t'
         , ROWTERMINATOR ='\r\n '
      );
