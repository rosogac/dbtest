SET NOCOUNT ON;
DECLARE @RowCount INT

SET @RowCount = 1

BEGIN TRANSACTION

WHILE @RowCount < 11

BEGIN

	INSERT INTO ITEM_CATALOGUE..IC_BRAND
	(
	BRAND_ID, 
	BRAND_NAME, 
	BRAND_DESC
	)
	VALUES
		(1000 + @RowCount
		, CONCAT('BRND_',@RowCount)
		, CONCAT('BRND_DESC_',@RowCount)
		)

	SET @RowCount = @RowCount + 1
END
COMMIT