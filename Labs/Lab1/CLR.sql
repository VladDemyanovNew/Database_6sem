USE social_network;
GO
-- Configuration
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;
-- When TRUSTWORTHY is 0/False/Off, SQL Server prevents the database 
-- from accessing resources in other databases
ALTER DATABASE social_network SET TRUSTWORTHY ON;
GO

-- Creating assebly
CREATE ASSEMBLY lab3_clr
from 'D:\University\SixthSem\Databases_6sem\Labs\Lab3\Lab3\obj\Debug\Lab3.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS
GO

-- Creating procedures
CREATE PROCEDURE PGET_OTHER_SOCIAL_NETWORKS_CREDS @startDate DATETIME, @endDate DATETIME
AS
EXTERNAL NAME lab3_clr.StoredProcedures.GetOtherSocialNetworksCreds;

CREATE PROCEDURE PCOPY_FILE @sourceFile nvarchar(100), @destFile nvarchar(100)
AS
EXTERNAL NAME lab3_clr.StoredProcedures.CopyFile;
GO

-- Creating CLR user defined types
CREATE TYPE dbo.email
EXTERNAL NAME lab3_clr.Email;

CREATE TYPE dbo.other_creds
EXTERNAL NAME lab3_clr.OtherCreds;
GO

-- Testing CLR procedures
SELECT * FROM OTHER_SOCIAL_NETWORKS_CREDS;
EXEC PGET_OTHER_SOCIAL_NETWORKS_CREDS '2003-01-01', '2005-01-01';

DECLARE @source_path  nvarchar(100) = 'D:\\University\\SixthSem\\Databases_6sem\\Labs\\Lab3\\Files\\SourceFile.txt';
DECLARE @dest_path nvarchar(100) = 'D:\\University\\SixthSem\\Databases_6sem\\Labs\\Lab3\\Files\\DestFile.txt';

EXEC PCOPY_FILE @source_path, @dest_path;
GO

-- Testing CLR user defined types
DECLARE @test email = 'test@mail.ru';
SELECT @test;
SELECT @test.ToString();
GO

DECLARE @test other_creds = '   facebook    login passw   ';
SELECT @test;
SELECT @test.ToString();
GO

DROP PROCEDURE PGET_OTHER_SOCIAL_NETWORKS_CREDS;
DROP PROCEDURE PCOPY_FILE;
DROP TYPE dbo.email;
DROP TYPE dbo.other_creds
DROP ASSEMBLY lab3_clr;