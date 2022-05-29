CREATE TABLE Reports
(
  Id INTEGER GENERATED ALWAYS AS IDENTITY,
  Data XMLTYPE,
  
  PRIMARY KEY(Id)
);

CREATE INDEX test_xmlindex ON Reports (Data)
INDEXTYPE IS XDB.XMLIndex;
-- parameters ('paths (include (/root/a/@test))');

-- DROP TABLE Reports;

CREATE OR REPLACE FUNCTION CountComments(PostId number) RETURN NUMBER IS
  CommentsCount number;
BEGIN
  SELECT COUNT(*) INTO CommentsCount
  FROM COMMENTS
  WHERE POST_ID = PostId;
  
  RETURN CommentsCount;
END;

CREATE OR REPLACE FUNCTION CountLikes(PostId number) RETURN NUMBER IS
  LikesCount number;
BEGIN
  SELECT COUNT(*) INTO LikesCount
  FROM LIKES
  WHERE POST_ID = PostId;
  
  RETURN LikesCount;
END;

CREATE OR REPLACE FUNCTION GetCurrentDate RETURN VARCHAR IS
  CurrentDate VARCHAR(32);
BEGIN
  SELECT TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS')
  INTO CurrentDate
  FROM DUAL;
  
  RETURN CurrentDate;
END;

CREATE OR REPLACE PROCEDURE GenerateReportXml (UserId INTEGER, ResultXml OUT XMLTYPE) AS
BEGIN
  SELECT XMLelement("Activity",
    XMLelement("TimeStamp", GetCurrentDate),
    (SELECT XMLagg(XMLelement("User", XMLforest(NICKNAME AS "Name")))
     FROM USERS WHERE ID = 1),
    (SELECT XMLelement("Posts",
      XMLagg(XMLelement("Post",
        XMLforest(
          CONTENT AS "Content",
          CountComments(ID) AS "Comments",
          CountLikes(ID) AS "Likes"
        )
      )))
     FROM POSTS WHERE OWNER_ID = 1)
  ) INTO ResultXml
  FROM dual;
END;

CREATE OR REPLACE PROCEDURE SnapshotUserActivity (UserId INTEGER) IS
  ReportXml XMLTYPE;
BEGIN
  GenerateReportXml(UserId, ReportXml);
  INSERT INTO Reports(Data)
  VALUES(ReportXml);
END;

-- Testing..
DECLARE
  UserId INTEGER := 1;
BEGIN
  SnapshotUserActivity(UserId);
  
  select extractvalue(Data, '/Activity/User/Name') from Reports;
  select r.Data.GETSTRINGVAL() xml from Reports r;
END;