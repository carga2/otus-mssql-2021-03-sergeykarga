CREATE OR ALTER PROCEDURE dbo.GetNewInvoice
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER, --������������� �������
			@Message NVARCHAR(4000),--���������� ���������
			@MessageType Sysname,--��� ����������� ���������
			@ReplyMessage NVARCHAR(4000),--�������� ���������
			@InvoiceID INT,
			@Object INT,
			@TargetObject INT,
			@ReplyCode INT,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	--����� �������� � �� �� 1 ���������
	--1 ������������ �� MS
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueuePurposes; 

	SELECT @Message; --������� � ������� ���������� �������

	SET @xml = CAST(@Message AS XML); -- �������� xml �� ��������

	--�������� InvoiceID �� xml
	SELECT @InvoiceID = R.Iv.value('@id','INT'), @Object = R.Iv.value('@Object','INT')
	FROM @xml.nodes('/RequestMessage/pr') as R(Iv);

	select [Object] from dbo.TargetProcesses where id = @InvoiceID

	select 
		@ReplyCode = case when @TargetObject is null and  @Object is not null then 1 -- ��������� ��������, �������� � ����� �������. �������� dbo.Processes
						  when @TargetObject is not null and  @Object is null then 2 -- �������� @@TargetObject � dbo.Processes
						  when @TargetObject <= @Object then 3 -- ����������. �������� dbo.Processes
						  else 4 -- �������� @Object � dbo.TargetProcesses
					end

	if @ReplyCode = 4
	begin
		UPDATE dbo.TargetProcesses
		SET [Object] = @Object
		WHERE id = @InvoiceID;
	end
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --� ���. ��������� ������
	
	-- Confirm and Send a reply
	IF @MessageType=N'//Purposes/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =(SELECT @ReplyCode as ReplyCode, @InvoiceID as id, @Object as [Object]		
							  FOR XML raw, root('ReplyMessage'));  
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//Purposes/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;--������� ������ �� ������� �������
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; --� ���

	COMMIT TRAN;
END