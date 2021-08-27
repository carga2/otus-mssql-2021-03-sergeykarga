use WideWorldImporters;

alter database WideWorldImporters add filegroup MyFileData
go
alter database WideWorldImporters add file
(
	name = 'myFileData'
	,filename = 'D:\mssql\myFileData.ndf'
	,size = 1097152KB
	,filegrowth = 65536KB
) to filegroup MyFileData
go

create partition function fnMyPartition(date) as range right for values
(
	'20130101','20140101','20150101','20160101', '20170101'
)
go

create partition scheme schmMyPartition as partition fnMyPartition all to (MyFileData)
go


CREATE TABLE [Sales].[MyOrderLines](
	[OrderLineID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	OrderDate date not null,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[PickedQuantity] [int] NOT NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL
)  ON schmMyPartition (OrderDate)

ALTER TABLE [Sales].[MyOrderLines] ADD CONSTRAINT PK_Sales_MyOrderLines
PRIMARY KEY CLUSTERED  (OrderDate, [OrderLineID])
 ON schmMyPartition (OrderDate);
go

 exec master ..xp_cmdshell ' bcp "select  [OrderLineID],ol.[OrderID],o.OrderDate,[StockItemID],[Description],[PackageTypeID],[Quantity],[UnitPrice],[TaxRate],[PickedQuantity],ol.[PickingCompletedWhen],ol.[LastEditedBy],ol.[LastEditedWhen]  from [WideWorldImporters].[Sales].[OrderLines] ol  join WideWorldImporters.[Sales].[Orders] o on o.OrderID = ol.OrderID" queryout "D:\mssql\MyOrders.txt" -T -w -t "@eu&$" -S DESKTOP-4K4HDH9'
 
 DECLARE 
	@path VARCHAR(256),
	@FileName VARCHAR(256),
	@onlyScript BIT, 
	@query	nVARCHAR(MAX),
	@dbname VARCHAR(255),
	@batchsize INT
	
	SELECT @dbname = DB_NAME();
	SET @batchsize = 1000;

	SET @path = 'D:\mssql\';
	SET @FileName = 'MyOrders.txt';
	SET @onlyScript = 0;
	
	BEGIN TRY

		IF @FileName IS NOT NULL
		BEGIN
			SET @query = 'BULK INSERT ['+@dbname+'].[Sales].[MyOrderLines]
				   FROM "'+@path+@FileName+'"
				   WITH 
					 (
						BATCHSIZE = '+CAST(@batchsize AS VARCHAR(255))+', 
						DATAFILETYPE = ''widechar'',
						FIELDTERMINATOR = ''@eu&$'',
						ROWTERMINATOR =''\n'',
						KEEPNULLS,
						TABLOCK        
					  );'

			PRINT @query

			IF @onlyScript = 0
				EXEC sp_executesql @query 
			PRINT 'Bulk insert '+@FileName+' is done, current time '+CONVERT(VARCHAR, GETUTCDATE(),120);
		END;
	END TRY

	BEGIN CATCH
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_MESSAGE() AS ErrorMessage; 

		PRINT 'ERROR in Bulk insert '+@FileName+' , current time '+CONVERT(VARCHAR, GETUTCDATE(),120);

	END CATCH
	
select Count(*) AS InvoiceLines from [Sales].MyOrderLines;
GO

select  $partition.fnMyPartition(OrderDate) as [partition]
		,count(*) as [count]
		,min(OrderDate) as startd
		,max(OrderDate) as endd
from Sales.MyOrderLines
group by $PARTITION.fnMyPartition(OrderDate) 
order by [partition] ;  


-- PS
-- в дз конечно проще использовать что-нибудь типа insert from select
-- мне нравится bcp и bulk insert, это быстро)
