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

DELETE dbo.SUBSCRIPTIONS WHERE OWNER_ID = 1;
SELECT * FROM dbo.SUBSCRIPTIONS;

-- 3. Borrowing rights
CREATE OR ALTER PROCEDURE dbo.SampleProcedure
WITH EXECUTE AS 'User1' AS
BEGIN
	SELECT * FROM dbo.USERS;
END;
-- DROP PROCEDURE dbo.DeleteSubscription;

alter authorization on dbo.DeleteSubscription to User1;
grant execute on dbo.SampleProcedure to User1;

SETUSER 'User1';
EXEC dbo.SampleProcedure;
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
	filepath = 'D:\Tests\SqlServerLogs\',
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

-- 15.
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'admin';

CREATE CERTIFICATE CertificateForSKey
WITH SUBJECT = 'CertificateForSKey';

CREATE SYMMETRIC KEY SymmetricKey WITH
IDENTITY_VALUE = 'SymmetricKey',
ALGORITHM = AES_256,
KEY_SOURCE = 'admin'
ENCRYPTION BY CERTIFICATE CertificateForSKey;

OPEN SYMMETRIC KEY SymmetricKey
DECRYPTION BY CERTIFICATE CertificateForSKey;

DECLARE
	@Message NVARCHAR(16) = 'Hello world!',
	@EncryptedMessage NVARCHAR(256);

PRINT CONCAT('Pristine message:', ' ', @Message);
SET @EncryptedMessage = EncryptByKey(Key_GUID('SymmetricKey'), @Message);
PRINT CONCAT('Encrypted message:', ' ', @EncryptedMessage);
SET @Message = DecryptByKey(@EncryptedMessage);
PRINT CONCAT('Decrypted message:', ' ', @Message);

CLOSE SYMMETRIC KEY SymmetricKey;

-- 17.
USE DVR_PSCA;

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE CertificateForSKey;

ALTER DATABASE DVR_PSCA
SET ENCRYPTION ON;

SELECT * FROM sys.dm_database_encryption_keys;

ALTER DATABASE DVR_PSCA
SET ENCRYPTION OFF;

-- 18.
select HashBytes('SHA1', 'hello');

-- 19.
select * from sys. certificates;
select SIGNBYCERT(261, N'Hello world', N'pGFD4bb925DGvbd2439587y');
select VERIFYSIGNEDBYCERT(261, N'Hello world', 0x0100050204000000BE63038B1CD92A647168035F0B8A474D60AB4D0936C113D5FFF12B6F852397443BB1C93F3E370EFC759625E33B5E0A526D554370354C2D4C2357ABB90ADE19B904FD4196E0A0D939A54DEDEFD7009C830008BC0FE694E633BD21D8FF71C018945F288C5BB013E692A1D130B64C8527BDB213495EC56433272ACCD9C7F7C27AD79D53B91A85DA0B44A87E8F5E3E38F88247CA233B246F1C221B58D8AF7DE063BCD926872617C673B982633C90619E15A8F39FBAFD857458DA64CA0F6E60EB5AF4295C2453B4D82D835A7A8BBE92D63B03057CC7E37D1130FED6264D653394C76A62AD3EE39B9229439584F0DF8BBD91D5B15E566D5C28A54642792E10CF9A7443);

-- 20.
BACKUP CERTIFICATE Shipping04
TO FILE = N'D:\Tests\SqlServerLogs\BackupCertificateForShipping04.cer'
WITH PRIVATE KEY
(
	file = N'D:\Tests\SqlServerLogs\BackupCertificateForShipping04.pvk',
	encryption by password = N'pGFD4bb925DGvbd2439587y',
	decryption by password = N'pGFD4bb925DGvbd2439587y'
);

USE MASTER;
BACKUP MASTER KEY TO FILE = 'D:\Tests\SqlServerLogs\BackupMasterKey.key' 
ENCRYPTION BY PASSWORD = 'admin';