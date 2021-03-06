ALTER FUNCTION fn_GetTopSales(@quantity int) RETURNS @RESULT TABLE (PID VARCHAR(50), TOTAL INT) AS
BEGIN
	DECLARE @TEMP TABLE(PID VARCHAR(50), AMT INT)
	INSERT INTO @TEMP SELECT ProductID, SUM(Amount) FROM dbo.Cart_Product GROUP BY ProductID;
	INSERT INTO @RESULT SELECT TOP (@quantity) PID, MAX(AMT) AS TOTAL FROM @TEMP GROUP BY PID ORDER BY TOTAL DESC;
	RETURN
END

SELECT * FROM fn_GetTopSales(8)

-----------------------------
CREATE FUNCTION fn_GetNewestProduct(@quantity int) RETURNS @RESULT TABLE (PID VARCHAR(50), ImportDate date) AS
BEGIN
	INSERT INTO @RESULT SELECT TOP (@quantity) ProductID, ImportDate FROM Product ORDER BY ImportDate DESC;
	RETURN
END

select * from fn_GetNewestProduct(8)
-----------------------------

create function fn_CheckingIfProductWasPurchasedByUser(@userid varchar(50), @productid varchar(50)) returns @result table(Purchased varchar(50)) as
begin
	insert into @result
		select distinct ProductID
		from Cart_Product
		inner join Cart 
		on Cart.CartID = Cart_Product.CartID
		where UserID = @userid and ProductID = @productid
	return
end

///update function

alter function fn_CheckingIfProductWasPurchasedByUser(@userid varchar(50), @productid varchar(50)) returns @result table(BillID varchar(50), CartID varchar(50), Status nvarchar(50)) as
begin
insert into @result
select Bill.BillID, Bill.CartID, Bill.Status
from Bill
inner join
(select Cart.CartID, UserID
from Cart
inner join
(select CartID
from Product
inner join Cart_Product on Product.ProductID = Cart_Product.ProductID
where Cart_Product.ProductID = @productid) as temp1
on cart.CartID = temp1.CartID
where UserID=@userid) as temp2
on Bill.CartID = temp2.CartID
where Bill.Status=N'Đã thanh toán'
return
end

---------------------------

create function fn_GetTwoVetor(@userid1 varchar(50), @userid2 varchar(50)) returns @result Table(User1Rating float, User2Rating float) as
begin
insert into @result
	select sub1.Star as User1Rating, sub2.Star as User2Rating from (select * from Rating where UserID = @userid1) sub1
	inner join (
	select * from Rating where UserID = @userid2) sub2 on sub1.ProductID = sub2.ProductID
return
end

---------------------------

create function fn_GetUnRatedProduct(@userid varchar(50)) returns @result Table(ProductID varchar(50)) as
begin
insert into @result
	select ProductID
	from Product
	where ProductID not in 
		(select ProductID
		from Rating
		where Rating.UserID = @userid)
return
end

---------------------------

create function fn_GetProductRatingFromTopSimilarUser(@userid varchar(50), @productid varchar(50)) 
returns @result table(SimilarityRate float, UserID varchar(50), Star float) as
begin
	insert into @result
	select TOP 10 SimilarityRate, UserID, Star
	from Similarity sub1
	inner join(
		select UserID, Star
		from Rating
		where ProductID = @productid) sub2
	on sub1.UserID1 = sub2.UserID or sub1.UserID2 = sub2.UserID
	where sub1.UserID1 = @userid or sub1.UserID2 = @userid
	order by SimilarityRate desc
return
end

---------------------------

create function fn_GetRecommendedProduct(@userid varchar(50)) returns
@result table(ProductID varchar(50)) as
begin
	insert into @result
	select Top 10 ProductID
	from
	(select *
	from Recommendation
	where UserID = @userid) as temp
	order by PredictedStar desc
return
end

---------------------------

create procedure proc_RemoveOldRecommendation @userid varchar(50)
as
begin
delete from Recommendation where UserID=@userid and ProductID in 
(select Recommendation.ProductID from Recommendation
inner join
(select Product.ProductID, Rating.UserID
	from Product, Rating
	where Rating.UserID = @userid and Product.ProductID = Rating.ProductID) as temp
on Recommendation.ProductID = temp.ProductID
where Recommendation.UserID = temp.UserID)
end

---------------------------