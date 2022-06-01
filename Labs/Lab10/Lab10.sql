-- 1. Authentication modes in SQL Server
-- Windows & Sql Server

-- 2. Logins & Users
-- There are two level of access to SQL Server: Instance user & DB user
USE master;
GO

CREATE LOGIN VDemyanov WITH PASSWORD='admin';
CREATE LOGIN SomeUser WITH PASSWORD='admin';

GO
USE SOCIAL_NETWORK;
GO

CREATE USER User1 FOR LOGIN VDemyanov;
CREATE USER User2 FOR LOGIN SomeUser;

EXEC sp_addrolemember 'db_datareader', 'User1';
EXEC sp_addrolemember 'db_datareader', 'User2';

CREATE ROLE User1Role;
CREATE ROLE User2Role;

GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.USERS TO User1Role;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.SUBSCRIPTIONS TO User2Role;

EXEC sp_addrolemember @rolename = 'User1Role', @membername = 'User1';
EXEC sp_addrolemember @rolename = 'User2Role', @membername = 'User2';

DELETE dbo.USERS WHERE ID = 2;
SELECT * FROM dbo.USERS;

-- 3. Borrowing rights
CREATE OR ALTER PROCEDURE dbo.DeleteSubscription @Id INT AS
-- WITH EXECUTE AS 'User1' AS
BEGIN
	DELETE dbo.USERS WHERE ID = @Id;
END;
-- DROP PROCEDURE dbo.DeleteSubscription;

alter authorization on dbo.DeleteSubscription to User1;
grant execute on dbo.DeleteSubscription to User1;

SETUSER 'User1';
EXEC dbo.DeleteSubscription 3;
SETUSER;

SELECT * FROM dbo.SUBSCRIPTIONS;

-- 4. SQL Server instance audit
GO
USE master;
GO

-- User must have the role sysadmin
CREATE SERVER AUDIT ServerAudit 
TO FILE
(
	filepath = 'D:\University\SixthSem\Databases_6sem\Labs\Lab10',
	maxsize = 0 mb,
	max_rollover_files = 0,
	reserve_disk_space = OFF
) WITH (queue_delay = 1000, on_failure = CONTINUE);

-- 11
GO
CREATE ASYMMETRIC KEY AsymmetricKey   
WITH ALGORITHM = RSA_2048   
ENCRYPTION BY PASSWORD = 'admin';

-- DROP ASYMMETRIC KEY AsymmetricKey;

DECLARE
	@Message NVARCHAR(16) = 'Hello world!',
	@EncryptedMessage NVARCHAR(256);

PRINT CONCAT('Pristine message:', ' ', @Message);
SET @EncryptedMessage = EncryptByAsymKey(AsymKey_ID('AsymmetricKey'), @Message);
PRINT CONCAT('Encrypted message:', ' ', @EncryptedMessage);
SET @Message = DecryptByAsymKey(AsymKey_ID('AsymmetricKey'), @EncryptedMessage, N'admin');
PRINT CONCAT('Decrypted message:', ' ', @Message);

-- 13.
GO
CREATE CERTIFICATE Shipping04
   ENCRYPTION BY PASSWORD = 'pGFD4bb925DGvbd2439587y'  
   WITH SUBJECT = 'Sammamish Shipping Records',   
   EXPIRY_DATE = '20241031';
-- DROP CERTIFICATE Shipping04   

DECLARE
	@Message NVARCHAR(16) = 'Hello world!',
	@EncryptedMessage NVARCHAR(256);

PRINT CONCAT('Pristine message:', ' ', @Message);
SET @EncryptedMessage = EncryptByCert(Cert_ID('Shipping04'), @Message);
PRINT CONCAT('Encrypted message:', ' ', @EncryptedMessage);
SET @Message = CAST(DecryptByCert(Cert_ID('Shipping04'), @EncryptedMessage, N'pGFD4bb925DGvbd2439587y') as nvarchar(58));
PRINT CONCAT('Decrypted message:', ' ', @Message);