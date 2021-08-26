SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--процедура изначальной отправки запроса в очередь таргета
create  PROCEDURE dbo.SendNewInvoice
	@invoiceId INT
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER; --open init dialog
	DECLARE @RequestMessage NVARCHAR(4000); --сообщение, которое будем отправлять
	
	BEGIN TRAN --начинаем транзакцию

	--Prepare the Message  !!!auto generate XML
	SELECT @RequestMessage = (SELECT id, [Object]
							  FROM dbo.Processes AS pr
							  WHERE id = @invoiceId
							  FOR XML AUTO, root('RequestMessage')); 
	
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//Purposes/SB/InitiatorService]
	TO SERVICE
	'//Purposes/SB/TargetService'
	ON CONTRACT
	[//Purposes/SB/Contract]
	WITH ENCRYPTION=OFF; 

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//Purposes/SB/RequestMessage]
	(@RequestMessage);

	update dbo.Processes set Process = N'Отправлено', [DateTime] = getdate() where id = @invoiceId

	--SELECT @RequestMessage AS SentRequestMessage;--we can write data to log
	COMMIT TRAN 
END
GO
