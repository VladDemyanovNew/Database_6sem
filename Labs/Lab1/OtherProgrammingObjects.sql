USE social_network;

CREATE FUNCTION COUNT_SUBSCRIBERS(@user_id INT = NULL) RETURNS INT AS
BEGIN
	declare @rc int = 0;
	set @rc = (select count(USERS.ID) from USERS
			   join SUBSCRIPTIONS on SUBSCRIPTIONS.SUBSCRIBER_ID = USERS.ID
			   where SUBSCRIPTIONS.OWNER_ID = @user_id);
	return @rc;
END;

SELECT * FROM USERS;

DECLARE @user_id INT = 5;
DECLARE @subscribers_count INT = dbo.COUNT_SUBSCRIBERS(@user_id);
PRINT CONCAT('Count of subscribers by userId=', @user_id, ': ', @subscribers_count);

CREATE VIEW USERS_POSTS_VIEW AS
SELECT USERS.NICKNAME AS USER_NICKNAME,
		POSTS.CONTENT AS POST_CONTENT
FROM USERS
JOIN POSTS ON USERS.ID = POSTS.OWNER_ID;

SELECT * FROM USERS_POSTS_VIEW;

CREATE TABLE USERS_LOGS
(
	ID INT IDENTITY(1, 1) NOT NULL,
	OPERATION_NAME NVARCHAR(10) NOT NULL,
	DESCRIPTION NVARCHAR(100),
);

DROP TRIGGER TR_USERS;

CREATE TRIGGER TR_USERS ON USERS AFTER INSERT, DELETE, UPDATE AS
BEGIN
	declare @ins int = (select count(*) from inserted),
			@del int = (select count(*) from deleted),
			@nickname nvarchar(30);
	if @ins > 0 and @del = 0
	begin
		set @nickname = (select NICKNAME from INSERTED);
		insert USERS_LOGS(OPERATION_NAME, DESCRIPTION)
			values('insert', CONCAT('Insert user with nickname=', @nickname));
	end;
	else if @ins = 0 and @del > 0
	begin
		set @nickname = (select NICKNAME from DELETED);
		insert USERS_LOGS(OPERATION_NAME, DESCRIPTION)
			values('delete', CONCAT('Delete user with nickname=', @nickname));
	end;
	else if @ins > 0 and @del > 0
	begin
		declare @nickname_old nvarchar(30) = (select NICKNAME from DELETED);
		set @nickname = (select NICKNAME from INSERTED);
		insert USERS_LOGS(OPERATION_NAME, DESCRIPTION)
			values('update', CONCAT('Update user nickname=', @nickname_old, ' on nickname=', @nickname));
	end;
	return;
END;

INSERT USERS (NICKNAME)
	VALUES('INSERT TRIGGER new');

UPDATE USERS SET NICKNAME = 'UPDATE TRIGGER' WHERE NICKNAME = 'INSERT TRIGGER new';

DELETE USERS WHERE NICKNAME = 'UPDATE TRIGGER';

SELECT * FROM USERS_LOGS;