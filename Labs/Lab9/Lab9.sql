USE SOCIAL_NETWORK;
GO

ALTER TABLE dbo.USERS
ADD REGISTRATION_DATE Date NOT NULL;

ALTER TABLE dbo.USERS
ADD TO_BE_DELETED BIT NOT NULL;

ALTER TABLE dbo.SUBSCRIPTIONS
ADD CREATE_DATE Date NOT NULL;

ALTER TABLE dbo.SUBSCRIPTIONS
ADD [TYPE] INT NOT NULL;

ALTER TABLE dbo.USERS
DROP COLUMN REGISTRATION_DATE;

ALTER TABLE dbo.USERS
DROP COLUMN TO_BE_DELETED;

ALTER TABLE dbo.SUBSCRIPTIONS
DROP COLUMN CREATE_DATE;

ALTER TABLE dbo.SUBSCRIPTIONS
DROP COLUMN [TYPE];
GO

CREATE OR ALTER PROCEDURE SeedDatabase AS
BEGIN
	DECLARE @TruncateAllQuery VARCHAR(256) = 'BEGIN SET QUOTED_IDENTIFIER ON; DELETE FROM ?; END';
	DECLARE @ResetIdentityQuery VARCHAR(256) = 'BEGIN DBCC CHECKIDENT(''?'', RESEED, 0); END';
	EXEC sp_MSForEachTable @TruncateAllQuery;
	EXEC sp_MSForEachTable @ResetIdentityQuery;

	DECLARE @RandomDate Date,
					@RandomOwnerId INT,
					@DoesAlreadyExist INT;

	DECLARE @RowsCounter INT = 1, @RowsCount INT = 1000;
	WHILE @RowsCounter <= @RowsCount
	BEGIN
		SET @RandomDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 3650), '2000-01-01');

		INSERT INTO dbo.USERS(NICKNAME, REGISTRATION_DATE, TO_BE_DELETED)
		VALUES (CONCAT('User ', @RowsCounter), @RandomDate, convert(bit, round(1*rand(),0)));
		SET @RowsCounter = @RowsCounter + 1;
	END;

	SET @RowsCounter = 1;
	WHILE @RowsCounter <= @RowsCount
	BEGIN
		DECLARE @RandomSubscriberId INT = FLOOR(RAND()*(@RowsCount-1)+1);

		SET @RandomOwnerId = FLOOR(RAND()*(@RowsCount-1)+1);
		SET @RandomDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 3650), CURRENT_TIMESTAMP);
		
		SELECT @DoesAlreadyExist = SUBSCRIBER_ID FROM dbo.SUBSCRIPTIONS
		WHERE OWNER_ID = @RandomOwnerId AND SUBSCRIBER_ID = @RandomSubscriberId;
		IF @DoesAlreadyExist IS NOT NULL
		BEGIN
			SET @RowsCounter = @RowsCounter + 1;
			CONTINUE;
		END;

		INSERT INTO dbo.SUBSCRIPTIONS(OWNER_ID, SUBSCRIBER_ID, CREATE_DATE, [TYPE])
		VALUES (@RandomOwnerId, @RandomSubscriberId, @RandomDate, FLOOR(RAND()*(4-1)+1));
		SET @RowsCounter = @RowsCounter + 1;
	END;
END;
GO

EXEC SeedDatabase;

-- Tasks ------------------

SELECT dbo.USERS.*, RANK() OVER(ORDER BY NICKNAME DESC) AS 'rank'
FROM dbo.USERS
ORDER BY 'rank';

INSERT INTO dbo.USERS (NICKNAME, REGISTRATION_DATE, TO_BE_DELETED)
VALUES ('New 6', '2022-06-03', 0),
('New 7', '2022-06-03', 0),
('New 8', '2022-06-03', 0),
('New 9', '2022-06-03', 0),
('New 10', '2022-06-03', 0);

-- Count of new users (current date)
SELECT COUNT(*) AS [Count]
FROM dbo.USERS
WHERE REGISTRATION_DATE = CONVERT(date, CURRENT_TIMESTAMP);

--  % of new users
SELECT REGISTRATION_DATE, [Percent] FROM
	(SELECT
		REGISTRATION_DATE,
		COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS [Percent]
	FROM dbo.USERS
	GROUP BY REGISTRATION_DATE) ALL_ROWS
WHERE REGISTRATION_DATE = CONVERT(date, CURRENT_TIMESTAMP);

-- % of users to be deleted
SELECT 
	TO_BE_DELETED,
	COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()
FROM dbo.USERS
GROUP BY TO_BE_DELETED;

-- % of users to be deleted in each partition
SELECT
	YEAR(REGISTRATION_DATE) AS [Year],
	TO_BE_DELETED AS [ToBeDeleted],
	COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY YEAR(REGISTRATION_DATE)) AS [Percent %]
FROM dbo.USERS
GROUP BY YEAR(REGISTRATION_DATE), TO_BE_DELETED;

-- Dividing resultset on pages
DECLARE
	@PageNum AS INT = 1,
  @PageSize AS INT = 20;

WITH C AS
	(SELECT
		ROW_NUMBER() OVER(ORDER BY ID) AS rownum,
		ID, 
		NICKNAME
	FROM dbo.USERS)
SELECT ID, NICKNAME
FROM C
WHERE rownum BETWEEN (@PageNum - 1) * @PageSize + 1 AND @PageNum * @PageSize
ORDER BY rownum;

-- Deletion of duplicates
CREATE TABLE dbo.Duplicates
(
	[Name] VARCHAR(32) NOT NULL
);
-- DROP TABLE dbo.Duplicates;

INSERT INTO dbo.Duplicates
VALUES ('Duplicate'),
('Duplicate'),
('Duplicate'),
('Normal');

SELECT * FROM dbo.Duplicates;

DELETE Duplicate FROM (
  SELECT *, rn = row_number() OVER(PARTITION BY [Name] ORDER BY [Name])
  FROM dbo.Duplicates) Duplicate
WHERE rn > 1;

-- Count of users' subscribers by year
WITH C AS
(
	SELECT
		YEAR(S.CREATE_DATE) AS [Year],
		U.ID,
		COUNT(*) [Subscribers]
	FROM dbo.USERS U
	JOIN dbo.SUBSCRIPTIONS S ON U.ID = S.OWNER_ID
	GROUP BY YEAR(S.CREATE_DATE), U.ID
)
SELECT * FROM C
WHERE YEAR(CURRENT_TIMESTAMP) - C.[Year] <= 20;

-- ttt

WITH C AS(
SELECT 
	[TYPE],
	SUBSCRIBER_ID,
	COUNT(*) OVER(PARTITION BY [TYPE] ORDER BY [TYPE]) AS Subs --OVER(PARTITION BY [TYPE] ORDER BY [TYPE])
FROM dbo.SUBSCRIPTIONS
GROUP BY [TYPE], SUBSCRIBER_ID
)
SELECT 
	[TYPE],
	SUBSCRIBER_ID,
	MAX(Subs) OVER (PARTITION BY [TYPE],Subs ORDER BY [TYPE])  
FROM C
GROUP BY [TYPE], SUBSCRIBER_ID
-- 341

SELECT 
	[TYPE],
	SUBSCRIBER_ID,
	COUNT(*) AS Subs,
	RANK() OVER (ORDER BY COUNT(*) ASC) AS RK
FROM dbo.SUBSCRIPTIONS
GROUP BY [TYPE], SUBSCRIBER_ID;

SELECT 
	DISTINCT([TYPE]),
	SUBSCRIBER_ID,
	COUNT(*) OVER (PARTITION BY [TYPE], SUBSCRIBER_ID ORDER BY [TYPE]) AS Subs
FROM dbo.SUBSCRIPTIONS;


