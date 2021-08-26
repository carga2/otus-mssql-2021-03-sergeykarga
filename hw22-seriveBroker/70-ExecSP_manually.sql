-- !!! сначала попробуем сначала отправить сообщения, без связки с процедурами обработки

use Purposes;

	select 
		s.id, s.Object, t.Object
	from [dbo].[Processes] s
	join [dbo].[TargetProcesses] t on t.id = s.id

--Send message
EXEC dbo.SendNewInvoice
	@invoiceId = 5;

--в какой очереди окажется сообщение?
SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorQueuePurposes;

SELECT CAST(message_body AS XML),*
FROM dbo.TargetQueuePurposes;

--проверим ручками, что все работает
--Target
EXEC dbo.GetNewInvoice;

--посмотрим текущие диалоги скрипт 00


--запрос на просмотр открытых диалогов
SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;


--Initiator
EXEC dbo.ConfirmInvoice;

-- проверим, что дата проставилась
select * from [dbo].[Processes]
--автоматизируем процесс
-- скрипт 80

--Send message
EXEC dbo.SendNewInvoice
	@invoiceId = 2;


