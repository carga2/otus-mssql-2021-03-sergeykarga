USE Purposes;

--создаем очередь
CREATE QUEUE TargetQueuePurposes;

--создаем сервис обслуживающий очередь
CREATE SERVICE [//Purposes/SB/TargetService]
       ON QUEUE TargetQueuePurposes
       ([//Purposes/SB/Contract]);
GO


CREATE QUEUE InitiatorQueuePurposes;

CREATE SERVICE [//Purposes/SB/InitiatorService]
       ON QUEUE InitiatorQueuePurposes
       ([//Purposes/SB/Contract]);
GO

--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/create-queue-transact-sql?view=sql-server-ver15
