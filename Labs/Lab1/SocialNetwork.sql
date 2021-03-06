-- CREATE DATABASE SOCIAL_NETWORK;
USE SOCIAL_NETWORK;

CREATE TABLE USERS
(
	ID INT IDENTITY(1, 1) NOT NULL,
	NICKNAME NVARCHAR(30) UNIQUE NOT NULL,

	CONSTRAINT PK_USER_ID PRIMARY KEY CLUSTERED (ID ASC)
);

ALTER TABLE USERS
ADD COORDINATES GEOMETRY NULL;

CREATE TABLE POSTS
(
	ID INT IDENTITY(1, 1) NOT NULL,
	CONTENT NVARCHAR(300) NOT NULL,
	OWNER_ID INT NOT NULL,

	CONSTRAINT PK_POSTS_ID PRIMARY KEY CLUSTERED (ID ASC),
	CONSTRAINT FK_POSTS_TO_USERS FOREIGN KEY (OWNER_ID) REFERENCES USERS(ID) ON DELETE CASCADE
);

CREATE NONCLUSTERED INDEX [NIX_POSTS_OWNER_ID]
ON [dbo].POSTS (OWNER_ID) WITH (ONLINE = ON);

CREATE TABLE COMMENTS
(
	ID INT IDENTITY(1, 1) NOT NULL,
	CONTENT NVARCHAR(100) NOT NULL,
	OWNER_ID INT NOT NULL,
	POST_ID INT NOT NULL,

	CONSTRAINT PK_COMMENTS_ID PRIMARY KEY CLUSTERED (ID ASC),
	CONSTRAINT FK_COMMENTS_TO_USERS FOREIGN KEY (OWNER_ID) REFERENCES USERS(ID),
	CONSTRAINT FK_COMMENTS_TO_POSTS FOREIGN KEY (POST_ID) REFERENCES POSTS(ID) ON DELETE CASCADE,
);

CREATE NONCLUSTERED INDEX [NIX_COMMENTS_OWNER_ID]
ON [dbo].COMMENTS (OWNER_ID) WITH (ONLINE = ON);

CREATE NONCLUSTERED INDEX [NIX_COMMENTS_POST_ID]
ON [dbo].COMMENTS (POST_ID) WITH (ONLINE = ON);

CREATE TABLE LIKES
(
	POST_ID INT NOT NULL,
	OWNER_ID INT NOT NULL,

	CONSTRAINT PK_LIKES PRIMARY KEY CLUSTERED (POST_ID ASC, OWNER_ID ASC),
	CONSTRAINT FK_LIKES_TO_POSTS FOREIGN KEY (POST_ID) REFERENCES POSTS(ID) ON DELETE CASCADE,
	CONSTRAINT FK_LIKES_TO_USERS FOREIGN KEY (OWNER_ID) REFERENCES USERS(ID)
);

CREATE TABLE SUBSCRIPTIONS
(
	OWNER_ID INT NOT NULL,
	SUBSCRIBER_ID INT NOT NULL,

	CONSTRAINT PK_SUBSCRIPTIONS PRIMARY KEY CLUSTERED (OWNER_ID ASC, SUBSCRIBER_ID ASC),
	CONSTRAINT FK_SUBSCRIPTIONS_TO_USERS FOREIGN KEY (OWNER_ID) REFERENCES USERS(ID) ON DELETE CASCADE,
	CONSTRAINT FK_SUBSCRIPTIONS_TO_SUBSCRIBERS FOREIGN KEY (SUBSCRIBER_ID) REFERENCES USERS(ID)
);

CREATE TABLE OTHER_SOCIAL_NETWORKS_CREDS
(
	ID INT IDENTITY(1, 1) NOT NULL,
	OWNER_ID INT NOT NULL,
	SOCIAL_NETWORK NVARCHAR(100) NOT NULL,
	USER_LOGIN EMAIL NOT NULL,
	USER_PASSWORD NVARCHAR(50) NOT NULL,
	REGISTRATION_DATE DATE NOT NULL,

	CONSTRAINT PK_OTHER_SOCIAL_NETWORKS_CREDS_ID PRIMARY KEY CLUSTERED (ID ASC),
	CONSTRAINT FK_OTHER_SOCIAL_NETWORKS_CREDS_TO_USERS 
	FOREIGN KEY (OWNER_ID) REFERENCES USERS(ID) ON DELETE CASCADE
);

DROP TABLE OTHER_SOCIAL_NETWORKS_CREDS;

SELECT * FROM OTHER_SOCIAL_NETWORKS_CREDS;

SELECT * FROM USERS;

INSERT OTHER_SOCIAL_NETWORKS_CREDS(
	OWNER_ID,
	SOCIAL_NETWORK,
	USER_LOGIN,
	USER_PASSWORD,
	REGISTRATION_DATE)
VALUES(11, 'VK', 'user5_vk@mail.ru', 'user5_vk', '2001-01-18'),
		(6, 'Facebook', 'user2_Facebook@mail.ru', 'user2_Facebook', '2004-11-12'),
		(9, 'Microsoft', 'user4_Microsoft@mail.ru', 'user4_Microsoft', '2005-05-05'),
		(7, 'Facebook', 'user3_Facebook@mail.ru', 'user3_Facebook', '2003-03-22');

insert users (nickname)
		values('user1'),
			  ('user2'),
			  ('user3');

insert posts (content, owner_id)
		values('content1', 2),
			  ('content2', 2),
			  ('content3', 2),
			  ('content4', 3);

insert comments (content, owner_id, post_id)
		values('content1', 1, 1),
			  ('content2', 1, 2),
			  ('content3', 2, 2),
			  ('content4', 3, 3);

insert likes (post_id, owner_id)
		values(2, 1),
			  (1, 1),
			  (1, 2),
			  (3, 3);


insert subscriptions (owner_id, subscriber_id)
			values(2, 2),
				  (2, 3);