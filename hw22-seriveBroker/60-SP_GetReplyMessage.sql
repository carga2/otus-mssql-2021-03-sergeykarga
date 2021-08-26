use Purposes;
GO
CREATE or alter PROCEDURE dbo.ConfirmInvoice
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER, --����� �������
			@ReplyReceivedMessage NVARCHAR(1000) ,
			@xml xml,
			@ReplyCode int,
			@InvoiceID int,
			@Object int
	
	BEGIN TRAN; 

	--������� ��������� �� ������� ����������
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueuePurposes; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --������� ������ �� ������� ����������
		--��� ��������� ������� ������ ��������� ���
		--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/end-conversation-transact-sql?view=sql-server-ver15
		
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; --� �������

		SET @xml = CAST(@ReplyReceivedMessage AS XML); -- �������� xml �� ��������

		SELECT 
			@ReplyCode = R.Iv.value('@ReplyCode','INT'), 
			@InvoiceID = R.Iv.value('@id','INT'), 
			@Object = R.Iv.value('@Object','INT')
		FROM @xml.nodes('/ReplyMessage/row') as R(Iv);

		if @ReplyCode = 1
		begin
			update dbo.Processes
			set [DateTime] = getdate(), Process = N'��������', Rating = (select max(Rating) + 1 from dbo.Processes)
			where id = @InvoiceID
		end

		if @ReplyCode = 2
		begin
			update dbo.Processes
			set [DateTime] = getdate(), Process = N'����������������', [Object] = @Object
			where id = @InvoiceID
		end

		if @ReplyCode = 3
		begin
			update dbo.Processes
			set [DateTime] = getdate(), Process = N'����������'
			where id = @InvoiceID
		end

	COMMIT TRAN; 
END


