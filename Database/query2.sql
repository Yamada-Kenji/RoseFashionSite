drop function FN_GET1PAGE
create FUNCTION FN_GET1PAGE(@IDList dbo.ProductIDs readonly) RETURNS @result table(pname nvarchar(MAX)) AS
BEGIN
	insert into @result 
		select Product.Name as pname 
		from Product
		inner join @IDList as idls on Product.ProductID = idls.ProductID;
	return
END 

DECLARE @pids AS ProductIDs 
INSERT INTO @pids VALUES('PR-1'),('PR-10'),('PR-11')  
SELECT * from FN_GET1PAGE(@pids)
