CREATE OR ALTER PROCEDURE dbo.GetNewInvoice
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER, --идентификатор диалога
			@Message NVARCHAR(4000),--полученное сообщение
			@MessageType Sysname,--тип полученного сообщени€
			@ReplyMessage NVARCHAR(4000),--ответное сообщение
			@InvoiceID INT,
			@Object INT,
			@TargetObject INT,
			@ReplyCode INT,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	--можно выбирать и не по 1 сообщению
	--1 рекомендаци€ от MS
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueuePurposes; 

	SELECT @Message; --выводим в консоль полученный месседж

	SET @xml = CAST(@Message AS XML); -- получаем xml из мессаджа

	--получаем InvoiceID из xml
	SELECT @InvoiceID = R.Iv.value('@id','INT'), @Object = R.Iv.value('@Object','INT')
	FROM @xml.nodes('/RequestMessage/pr') as R(Iv);

	select [Object] from dbo.TargetProcesses where id = @InvoiceID

	select 
		@ReplyCode = case when @TargetObject is null and  @Object is not null then 1 -- ќтправить повторно, поставив в конец очереди. ќбновить dbo.Processes
						  when @TargetObject is not null and  @Object is null then 2 -- «аписать @@TargetObject в dbo.Processes
						  when @TargetObject <= @Object then 3 -- ќбработано. ќбновить dbo.Processes
						  else 4 -- «аписать @Object в dbo.TargetProcesses
					end

	if @ReplyCode = 4
	begin
		UPDATE dbo.TargetProcesses
		SET [Object] = @Object
		WHERE id = @InvoiceID;
	end
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --в лог. замедл€ет работу
	
	-- Confirm and Send a reply
	IF @MessageType=N'//Purposes/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =(SELECT @ReplyCode as ReplyCode, @InvoiceID as id, @Object as [Object]		
							  FOR XML raw, root('ReplyMessage'));  
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//Purposes/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;--закроем диалог со стороны таргета
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; --в лог

	COMMIT TRAN;
END