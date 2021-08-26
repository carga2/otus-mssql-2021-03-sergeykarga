--Create Message Types for Request and Reply messages
USE Purposes
-- For Request
CREATE MESSAGE TYPE
[//Purposes/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML;
-- For Reply
CREATE MESSAGE TYPE
[//Purposes/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 

GO

--create contract
--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/create-contract-transact-sql?view=sql-server-ver15
CREATE CONTRACT [//Purposes/SB/Contract]
      ([//Purposes/SB/RequestMessage]
         SENT BY INITIATOR,
       [//Purposes/SB/ReplyMessage]
         SENT BY TARGET
      );
GO

