PRAGMA foreign_keys=on;

CREATE TABLE "Users" (
	"Id"	INTEGER NOT NULL,
	"Nickname"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("Id" AUTOINCREMENT)
);

CREATE TABLE "Posts" (
	"Id"	INTEGER NOT NULL,
	"Content"	TEXT NOT NULL,
	"OwnerId"	INTEGER NOT NULL,
	"Title"	TEXT NOT NULL UNIQUE,
	FOREIGN KEY("OwnerId") REFERENCES "Users"("Id") ON DELETE CASCADE,
	PRIMARY KEY("Id" AUTOINCREMENT)
);

CREATE TABLE "Histories" (
	"Id"	INTEGER NOT NULL,
	"Action"	TEXT NOT NULL,
	"Info"	TEXT NOT NULL,
	"TableName"	TEXT NOT NULL,
	"Timestamp"	TEXT NOT NULL,
	PRIMARY KEY("Id" AUTOINCREMENT)
);

CREATE VIEW UsersPosts AS
SELECT * FROM Users U
JOIN Posts P ON U.Id = P.OwnerId;

CREATE TRIGGER HistoryLogITG AFTER INSERT
ON Posts
BEGIN
   INSERT INTO Histories(Action, Info, TableName, Timestamp)
   VALUES ('INSERT', 'post id: ' || new.id, 'Posts', datetime('now'));
END;

CREATE TRIGGER HistoryLogUTG AFTER UPDATE
ON Posts
BEGIN
   INSERT INTO Histories(Action, Info, TableName, Timestamp)
   VALUES ('UPDATE', 'post id: ' || old.id, 'Posts', datetime('now'));
END;

CREATE TRIGGER HistoryLogDTG AFTER DELETE
ON Posts
BEGIN
   INSERT INTO Histories(Action, Info, TableName, Timestamp)
   VALUES ('DELETE', 'post id: ' || old.id, 'Posts', datetime('now'));
END;

BEGIN TRANSACTION;
INSERT INTO Users(Nickname)
VALUES('USER3');
INSERT INTO Users(Nickname)
VALUES('USER4');
COMMIT;

ROLLBACK;

INSERT INTO Users(Nickname)
VALUES('User 1'),
('User 2');

INSERT INTO Posts(Content, Title, OwnerId)
VALUES('Post 1', 'Post 1', 1),
('Post 2', 'Post 2', 1);

DELETE FROM Posts WHERE Id = 1;

SELECT * FROM Users;
SELECT * FROM Posts;
SELECT * FROM Histories;
SELECT * FROM UsersPosts;