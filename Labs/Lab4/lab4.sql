USE social_network;
GO

CREATE OR ALTER PROCEDURE dbo.FindNearestNeighbor(@UserId INT, @Result INT OUT) AS
BEGIN
	DECLARE @UserCoordinates GEOMETRY;
	SELECT @UserCoordinates = COORDINATES 
	FROM dbo.USERS;

	DECLARE 
		@CurrentUserCoordinates GEOMETRY,
		@CurrentUserId INT,
		@NearestNeighborId INT,
		@IsFirst BIT = 1,
		@ShortestDistance FLOAT;
	
	DECLARE users_cursor CURSOR FOR
	SELECT COORDINATES, ID FROM dbo.USERS
	WHERE COORDINATES IS NOT NULL;

	OPEN users_cursor;
	FETCH NEXT FROM users_cursor INTO 
		@CurrentUserCoordinates,
		@CurrentUserId;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @CurrentDistance FLOAT = @CurrentUserCoordinates.STDistance(@UserCoordinates);
		IF @CurrentUserId != @UserId AND (@IsFirst = 1 OR @CurrentDistance < @ShortestDistance)
		BEGIN
			SET @NearestNeighborId = @CurrentUserId;
			SET @ShortestDistance = @CurrentDistance;
			SET @IsFirst = 0;
		END;

		FETCH NEXT FROM users_cursor INTO 
			@CurrentUserCoordinates,
			@CurrentUserId;
	END;

	CLOSE users_cursor;
	DEALLOCATE users_cursor;

	SET @Result = @NearestNeighborId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.DisplayShortestWay(@From GEOMETRY, @To GEOMETRY) AS
BEGIN
	DECLARE @Way GEOMETRY = @From.ShortestLineTo(@To);
	SET @Way.STSrid = 32768;

	SELECT ogr_geometry FROM dbo.gadm40_blr_2
	UNION ALL
	SELECT COORDINATES.STBuffer(0.05) AS name_1 FROM dbo.USERS
	UNION ALL
	SELECT @Way.STBuffer(0.02);
END;
GO

CREATE OR ALTER PROCEDURE dbo.DisplayWayDiscricts(@From GEOMETRY, @To GEOMETRY) AS
BEGIN
	DECLARE @Way GEOMETRY = @From.ShortestLineTo(@To);
	SET @Way.STSrid = 32768;

	SELECT ogr_geometry FROM dbo.gadm40_blr_2
	WHERE ogr_geometry.STIntersects(@Way.STBuffer(0.02)) = 1
	UNION ALL
	SELECT @From.STBuffer(0.05)
	UNION ALL
	SELECT @To.STBuffer(0.05)
	UNION ALL
	SELECT @Way.STBuffer(0.02);
END;
GO

CREATE OR ALTER PROCEDURE dbo.TEST_PROCEDURE AS
BEGIN
	DECLARE
		@UserId INT = 7,
		@NearestNeighborId INT,
		@User1Coordinates GEOMETRY,
		@User2Coordinates GEOMETRY;

	EXEC dbo.FindNearestNeighbor @UserId, @NearestNeighborId OUTPUT;

	SELECT @User1Coordinates = Coordinates
	FROM dbo.USERS WHERE ID = @UserId;

	SELECT @User2Coordinates = Coordinates
	FROM dbo.USERS WHERE ID = @NearestNeighborId;

	EXEC dbo.DisplayWayDiscricts @User1Coordinates, @User2Coordinates;
END;

EXEC dbo.TEST_PROCEDURE;

GO


