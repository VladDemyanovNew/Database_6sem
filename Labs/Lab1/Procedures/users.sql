USE SOCIAL_NETWORK;

-- DROP PROCEDURE PGET_USER_SUBSCRIBERS;

CREATE PROCEDURE PGET_USER_SUBSCRIBERS @user_id INT AS
BEGIN
	select USERS.* from USERS
	join SUBSCRIPTIONS on SUBSCRIPTIONS.SUBSCRIBER_ID = USERS.ID
	where SUBSCRIPTIONS.OWNER_ID = @user_id;
END;

CREATE PROCEDURE PSUBSCRIBE @ownerId INT, @subscriberId INT AS
BEGIN
	insert SUBSCRIPTIONS(OWNER_ID, SUBSCRIBER_ID)
		values(@ownerId, @subscriberId);
END;

CREATE PROCEDURE PUNSUBSCRIBE @ownerId INT, @subscriberId INT AS
BEGIN
	delete SUBSCRIPTIONS where OWNER_ID = @ownerId and SUBSCRIBER_ID = @subscriberId;
END;

CREATE PROCEDURE PGET_ALL_USERS AS
BEGIN
	select * from USERS;
END;

CREATE PROCEDURE PGET_USER @user_id INT AS
BEGIN
	select * from USERS where ID = @user_id;
END;

CREATE PROCEDURE PCREATE_USER @nickname NVARCHAR(30) AS
BEGIN
	insert USERS (nickname)
		values(@nickname);
	select SCOPE_IDENTITY();
END;

CREATE PROCEDURE PUPDATE_USER @user_id INT, @nickname NVARCHAR(30) AS
BEGIN
	update USERS set NICKNAME = @nickname
	where ID = @user_id;
END;

CREATE PROCEDURE PDELETE_USER @user_id INT AS
BEGIN
	delete SUBSCRIPTIONS where OWNER_ID = @user_id;
	delete COMMENTS where OWNER_ID = @user_id;
	delete LIKES where OWNER_ID = @user_id;
	delete POSTS where OWNER_ID = @user_id;
	delete USERS where ID = @user_id;
END;

EXEC PGET_USER_SUBSCRIBERS 5;
EXEC PCREATE_USER 'testCreate';
EXEC PUPDATE_USER 1, 'testUpdate';
EXEC PDELETE_USER 30;

select * from USERS;
select * from SUBSCRIPTIONS;
select * from COMMENTS;
select * from POSTS;
select * from LIKES;
