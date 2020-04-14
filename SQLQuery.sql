ALTER FUNCTION FN_TOPSALE() RETURNS @RESULT TABLE (PID VARCHAR(50), TOTAL INT) AS
BEGIN
	DECLARE @TEMP TABLE(PID VARCHAR(50), AMT INT)
	INSERT INTO @TEMP SELECT ProductID, SUM(Amount) FROM dbo.Cart_Product GROUP BY ProductID;
	INSERT INTO @RESULT SELECT TOP 10 PID, MAX(AMT) AS TOTAL FROM @TEMP GROUP BY PID ORDER BY TOTAL DESC;
	RETURN
END

SELECT * FROM FN_TOPSALE()

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

---------------------------