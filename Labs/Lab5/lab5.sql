USE social_network;
GO

CREATE OR ALTER PROCEDURE dbo.GetCommentChildren @ParentId INT, @Level INT AS
BEGIN
	DECLARE @phId HIERARCHYID;
	SET @phId = (SELECT HID FROM dbo.COMMENTS WHERE ID = @ParentId);

	SELECT * FROM dbo.COMMENTS
	WHERE HID.IsDescendantOf(@phId) = 1 AND HID.GetLevel() = @Level;
END;
GO

CREATE OR ALTER PROCEDURE dbo.CreateChildComment
	@ParentId INT,
	@Content NVARCHAR(100),
	@OwnerId INT,
	@PostId INT
AS
BEGIN
	DECLARE 
		@ChildHID HIERARCHYID,
		@ParentHID HIERARCHYID;

	SET @ParentHID = (SELECT HID FROM dbo.COMMENTS WHERE ID = @ParentId);

	SELECT @ChildHID = MAX(HID)
	FROM dbo.COMMENTS
	WHERE HID.GetAncestor(1) = @ParentHID;

	INSERT INTO dbo.COMMENTS (CONTENT, OWNER_ID, POST_ID, HID)
	VALUES (@Content, @OwnerId, @PostId, @ParentHID.GetDescendant(@ChildHID, null));
END;
GO

CREATE OR ALTER PROCEDURE dbo.CherryPickComments @SubjectId INT, @DestParentId INT AS
BEGIN
	DECLARE 
		@SubjectHID HIERARCHYID,
		@SourceParentHID HIERARCHYID,
		@DestParentHID HIERARCHYID;

	SET @SubjectHID = (SELECT HID FROM dbo.COMMENTS WHERE ID = @SubjectId);
	SET @DestParentHID = (SELECT HID FROM dbo.COMMENTS WHERE ID = @DestParentId);

	SELECT @DestParentHID = @DestParentHID.GetDescendant(MAX(HID), NULL)
	FROM dbo.COMMENTS
	WHERE HID.GetAncestor(1) = @DestParentHID;

	UPDATE dbo.COMMENTS
	SET HID = HID.GetReparentedValue(@SubjectHID, @DestParentHID)
	WHERE HID.IsDescendantOf(@SubjectHID) = 1;
END;
GO

EXEC dbo.GetCommentChildren 11, 2;
EXEC dbo.CreateChildComment 34, 'test_child 4', 6, 4;
EXEC dbo.CherryPickComments 34, 10;


SELECT * FROM
dbo.COMMENTS;