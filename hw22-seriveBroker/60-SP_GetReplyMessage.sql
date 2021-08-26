use Purposes;
GO
CREATE or alter PROCEDURE dbo.ConfirmInvoice
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER, --хэндл диалога
			@ReplyReceivedMessage NVARCHAR(1000) ,
			@xml xml,
			@ReplyCode int,
			@InvoiceID int,
			@Object int
	
	BEGIN TRAN; 

	--получим сообщение из очереди инициатора
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueuePurposes; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --закроем диалог со стороны инициатора
		--оба участника диалога должны завершить его
		--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/end-conversation-transact-sql?view=sql-server-ver15
		
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; --в консоль

		SET @xml = CAST(@ReplyReceivedMessage AS XML); -- получаем xml из мессаджа

		SELECT 
			@ReplyCode = R.Iv.value('@ReplyCode','INT'), 
			@InvoiceID = R.Iv.value('@id','INT'), 
			@Object = R.Iv.value('@Object','INT')
		FROM @xml.nodes('/ReplyMessage/row') as R(Iv);

		if @ReplyCode = 1
		begin
			update dbo.Processes
			set [DateTime] = getdate(), Process = N'Повторно', Rating = (select max(Rating) + 1 from dbo.Processes)
			where id = @InvoiceID
		end

		if @ReplyCode = 2
		begin
			update dbo.Processes
			set [DateTime] = getdate(), Process = N'Синхронизировано', [Object] = @Object
			where id = @InvoiceID
		end

		if @ReplyCode = 3
		begin
			update dbo.Processes
			set [DateTime] = getdate(), Process = N'Обработано'
			where id = @InvoiceID
		end

	COMMIT TRAN; 
END


