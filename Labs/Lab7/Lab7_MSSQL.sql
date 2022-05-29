USE SOCIAL_NETWORK;
GO

CREATE TABLE dbo.Reports
(
	Id INT PRIMARY KEY IDENTITY(1, 1) NOT NULL,
	[Data] XML NULL
);

CREATE PRIMARY XML INDEX PXML_Reports_Data ON dbo.Reports ([Data]);

CREATE XML INDEX XMLPATH_Reports_Data ON Reports ([Data])
USING XML INDEX PXML_Reports_Data FOR PATH;

CREATE XML INDEX XMLPROPERTY_Reports_Data ON Reports ([Data])
USING XML INDEX PXML_Reports_Data FOR PROPERTY;

CREATE XML INDEX XMLVALUE_Reports_Data ON Reports ([Data])
USING XML INDEX PXML_Reports_Data FOR VALUE;
GO

CREATE OR ALTER FUNCTION dbo.CountComments (@PostId INT) RETURNS INT AS
BEGIN
	RETURN (SELECT COUNT(*) FROM dbo.COMMENTS WHERE POST_ID = @PostId);
END;
GO

CREATE OR ALTER FUNCTION dbo.CountLikes (@PostId INT) RETURNS INT AS
BEGIN
	RETURN (SELECT COUNT(*) FROM COMMENTS WHERE COMMENTS.POST_ID = @PostId);
END;
GO

CREATE OR ALTER PROCEDURE dbo.GenerateReportXml @UserId INT, @Report XML OUTPUT AS
BEGIN
	DECLARE @UserIdString NVARCHAR(10) = CAST(@UserId AS NVARCHAR(16));

	DECLARE @UserInfo NVARCHAR(1024) = 
	'(SELECT NICKNAME AS [Имя] FROM dbo.USERS WHERE Id = ' 
	+ @UserIdString + ' FOR XML PATH(''Пользователь''), TYPE)';

	DECLARE @ActivityInfo NVARCHAR(1024) =
	'(SELECT POSTS.CONTENT as [Контент], dbo.CountComments(POSTS.ID) AS [Комментарии], ' +
	'dbo.CountLikes(POSTS.ID) AS [Лайки]' + CHAR(13) + CHAR(10) +
	'FROM POSTS WHERE OWNER_ID = ' + @UserIdString + CHAR(13) + CHAR(10) +
	'FOR XML PATH(''Публикация''), TYPE) AS [Публикации]';

	DECLARE @Query NVARCHAR(1024) = 
	'SELECT GETDATE() AS [Дата], ' + @UserInfo + ', ' + @ActivityInfo +
	CHAR(13) + CHAR(10) +
	'FOR XML PATH(''''), TYPE, ROOT(''Активность'')';

	CREATE TABLE #QueryResult ([Data] XML);
	INSERT INTO #QueryResult EXEC sp_executesql @Query;
	SELECT TOP(1) @Report = [Data] FROM #QueryResult;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SnapshotUserActivity @UserId INT AS
BEGIN
	DECLARE @Report XML;
	EXEC dbo.GenerateReportXml @UserId, @Report OUTPUT;

	INSERT INTO dbo.Reports
	VALUES(@Report);
END;
GO

CREATE OR ALTER PROCEDURE dbo.GetXmlFromReport AS
BEGIN
	SELECT [Data].query('/Активность/Пользователь') FROM Reports;
END;

-- Testing
EXEC dbo.SnapshotUserActivity 2;
SELECT * FROM dbo.Reports;
EXEC dbo.GetXmlFromReport;

GO
-- DROP TABLE dbo.Reports;
-- DROP PROCEDURE dbo.GenerateReportXml;
-- DROP PROCEDURE dbo.SnapshotUserActivity;