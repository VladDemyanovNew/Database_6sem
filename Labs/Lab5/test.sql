USE social_network;
GO

SELECT * FROM dbo.COMMENTS;

ALTER TABLE dbo.COMMENTS
ADD HID HIERARCHYID NULL;
GO

-- Главный корень иерархии
INSERT INTO dbo.COMMENTS (CONTENT, OWNER_ID, POST_ID, HID)
VALUES ('comment 1', 6, 4, HIERARCHYID::GetRoot())

DECLARE @Id HIERARCHYID;

SELECT @Id = MAX(HID)
FROM dbo.COMMENTS
WHERE HID.GetAncestor(1) = HIERARCHYID::GetRoot();

SELECT @Id;

-- Потомок №1 на втором уровне
INSERT INTO dbo.COMMENTS (CONTENT, OWNER_ID, POST_ID, HID)
VALUES ('comment 2', 6, 4, HIERARCHYID::GetRoot().GetDescendant(@Id, null));

-- -------------------------------------------------------------------------- --
DECLARE @Id HIERARCHYID;

SELECT @Id = MAX(HID)
FROM dbo.COMMENTS
WHERE HID.GetAncestor(1) = HIERARCHYID::GetRoot();

-- Потомок №2 на втором уровне
INSERT INTO dbo.COMMENTS (CONTENT, OWNER_ID, POST_ID, HID)
VALUES ('comment 3', 6, 4, HIERARCHYID::GetRoot().GetDescendant(@Id, null));

SELECT @Id;

-- -------------------------------------------------------------------------- --
DECLARE @Id HIERARCHYID;

SELECT @Id = MAX(HID)
FROM dbo.COMMENTS
WHERE HID.GetAncestor(1) = HIERARCHYID::GetRoot();

-- Потомок №3 на втором уровне
INSERT INTO dbo.COMMENTS (CONTENT, OWNER_ID, POST_ID, HID)
VALUES ('comment 4', 6, 4, HIERARCHYID::GetRoot().GetDescendant(@Id, null));

SELECT @Id;

-- -------------------------------------------------------------------------- --
DECLARE @Id HIERARCHYID;

DECLARE @phId HIERARCHYID;
SELECT @phId = (SELECT HID FROM dbo.COMMENTS WHERE ID = 18);

SELECT @Id = MAX(HID)
FROM dbo.COMMENTS
WHERE HID.GetAncestor(1) = @phId;

-- Потомок №1 на третем уровне у комментария с Id = 10
INSERT INTO dbo.COMMENTS (CONTENT, OWNER_ID, POST_ID, HID)
VALUES ('comment 10->4', 6, 4, @phId.GetDescendant(@Id, null));

GO

SELECT HID.ToString(), HID.GetLevel(), *
FROM dbo.COMMENTS;

SELECT * FROM dbo.COMMENTS;

