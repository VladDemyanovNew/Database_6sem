USE social_network;

DECLARE @p1 geometry;  
SET @p1 = geometry::STGeomFromText('POINT (27 53)', 0); 
SET @p1.STSrid = 32768;

DECLARE @p2 geometry;  
SET @p2 = geometry::STGeomFromText('POINT (29 54)', 0); 
SET @p2.STSrid = 32768;

DECLARE @p3 geometry;  
SET @p3 = geometry::STGeomFromText('POINT (26 53)', 0); 
SET @p3.STSrid = 32768;
UPDATE dbo.USERS SET COORDINATES = @p3 WHERE ID = 17;

UPDATE dbo.USERS SET COORDINATES = @p1 WHERE ID = 7;
UPDATE dbo.USERS SET COORDINATES = @p2 WHERE ID = 9;

DECLARE @Result INT;
EXEC @Result = dbo.FindNearestNeighbor 7;
SELECT @Result;

declare @distance float = @p1.STDistance(@p2);
declare @line geometry;
select @distance as 'Distance';
select @line = @p1.ShortestLineTo(@p2);
set @line.STSrid = 32768;
select ogr_geometry from dbo.gadm40_blr_2
union all
select @line.STBuffer(0.03);


SELECT @g;

INSERT social_network.dbo.gadm40_blr_2(ogr_geometry, name_1)
VALUES(@g, 'point_test');

delete social_network.dbo.gadm40_blr_2 where name_1 = 'point_test';