-- !!! ������� ��������� ������� ��������� ���������, ��� ������ � ����������� ���������

use Purposes;

	select 
		s.id, s.Object, t.Object
	from [dbo].[Processes] s
	join [dbo].[TargetProcesses] t on t.id = s.id

--Send message
EXEC dbo.SendNewInvoice
	@invoiceId = 5;

--� ����� ������� �������� ���������?
SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorQueuePurposes;

SELECT CAST(message_body AS XML),*
FROM dbo.TargetQueuePurposes;

--�������� �������, ��� ��� ��������
--Target
EXEC dbo.GetNewInvoice;

--��������� ������� ������� ������ 00


--������ �� �������� �������� ��������
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

-- ��������, ��� ���� ������������
select * from [dbo].[Processes]
--�������������� �������
-- ������ 80

--Send message
EXEC dbo.SendNewInvoice
	@invoiceId = 2;


