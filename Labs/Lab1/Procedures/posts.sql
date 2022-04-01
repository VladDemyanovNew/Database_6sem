USE SOCIAL_NETWORK;

CREATE PROCEDURE PGET_ALL_POSTS AS
BEGIN
	select * from POSTS;
END;

CREATE PROCEDURE PGET_POST @post_id INT AS
BEGIN
	select * from POSTS where ID = @post_id;
END;

CREATE PROCEDURE PCREATE_POST @content NVARCHAR(300), @owner_id INT AS
BEGIN
	insert POSTS (CONTENT, OWNER_ID)
		values(@content, @owner_id);
	select SCOPE_IDENTITY();
END;

CREATE PROCEDURE PUPDATE_POST @post_id INT, @content NVARCHAR(300), @owner_id INT AS
BEGIN
	update POSTS set CONTENT = @content, OWNER_ID = @owner_id
	where ID = @post_id;
END;

CREATE PROCEDURE PDELETE_POST @post_id INT AS
BEGIN
	delete POSTS where ID = @post_id;
END;

select * from POSTS;
select * from USERS;

EXEC PDELETE_POST 8;
EXEC PCREATE_POST 'testCreate', 17;