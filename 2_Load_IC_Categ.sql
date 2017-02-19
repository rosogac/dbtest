SET NOCOUNT ON;
DECLARE @RowCount INT

SET @RowCount = 1

BEGIN TRANSACTION

WHILE @RowCount < 6

BEGIN

	INSERT INTO ITEM_CATALOGUE..IC_CATEGORY
	(
	CATEGORY_ID, 
	CATEGORY_NAME, 
	CATEGORY_DESC
	)
	VALUES
		(100 + @RowCount
		, CONCAT('CAT_',@RowCount)
		, CONCAT('CAT_DESC_',@RowCount)
		)

	SET @RowCount = @RowCount + 1
END
COMMIT
