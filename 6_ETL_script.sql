--SELECT * INTO PA_ITEM_BUFFER FROM PA_ITEM WHERE 1 = 0; --initial buffer table creation;
--We will use a buffer table to perform E/T of data, followed by the Load via MERGE

DELETE FROM PROMOTION_APPLICATION..PA_ITEM_BUFFER; --clean up buffer table for next load

---loading current data in buffer table---
INSERT INTO PROMOTION_APPLICATION..PA_ITEM_BUFFER
SELECT 
	a.ITEM_ID,
	a.ITEM_NAME,
	a.ITEM_DESCRIPTION,
	a.BRAND_ID,
	b.BRAND_NAME,
	a.CATEGORY_ID,
	c.CATEGORY_NAME,
	pr.PRICE_DATE,
	pr.PRICE_VALUE

FROM ITEM_CATALOGUE..IC_ITEM a
INNER JOIN ITEM_CATALOGUE..IC_BRAND b
ON a.BRAND_ID = b.BRAND_ID

INNER JOIN ITEM_CATALOGUE..IC_CATEGORY c
ON a.CATEGORY_ID = c.CATEGORY_ID

INNER JOIN 
	(SELECT prc.ITEM_ID, prc.PRICE_DATE, prc.PRICE_VALUE 
	FROM
	PRICING_APPLICATION..PR_PRICE prc
	INNER JOIN 
	(
	SELECT p.ITEM_ID,MAX(p.PRICE_DATE) AS PRICE_DATE 
	FROM PRICING_APPLICATION..PR_PRICE p
	GROUP BY p.ITEM_ID
	) p 
	ON prc.ITEM_ID = p.ITEM_ID 
	AND prc.PRICE_DATE = p.PRICE_DATE
	) pr
ON a.ITEM_ID = pr.ITEM_ID
;

GO

---compare buffer table with production table and update data as needed---
BEGIN TRANSACTION;

MERGE PROMOTION_APPLICATION..PA_ITEM AS dest
USING PROMOTION_APPLICATION..PA_ITEM_BUFFER AS src
ON (dest.ITEM_ID = src.ITEM_ID)
WHEN NOT MATCHED BY TARGET
	THEN INSERT 
	(
	ITEM_ID,
	ITEM_NAME,
	ITEM_DESCRIPTION,
	BRAND_ID,
	BRAND_NAME,
	CATEGORY_ID,
	CATEGORY_NAME,
	PRICE_DATE,
	PRICE_VALUE
	)
	VALUES
	(
	src.ITEM_ID,
	src.ITEM_NAME,
	src.ITEM_DESCRIPTION,
	src.BRAND_ID,
	src.BRAND_NAME,
	src.CATEGORY_ID,
	src.CATEGORY_NAME,
	src.PRICE_DATE,
	src.PRICE_VALUE
	)
WHEN MATCHED THEN UPDATE 
SET dest.ITEM_NAME = src.ITEM_NAME, 
	dest.ITEM_DESCRIPTION = src.ITEM_DESCRIPTION,
	dest.BRAND_ID = src.BRAND_ID,
	dest.BRAND_NAME = src.BRAND_NAME,
	dest.CATEGORY_ID = src.CATEGORY_ID,
	dest.CATEGORY_NAME = src.CATEGORY_NAME,
	dest.PRICE_DATE = src.PRICE_DATE,
	dest.PRICE_VALUE = src.PRICE_VALUE
WHEN NOT MATCHED BY SOURCE THEN DELETE;
COMMIT TRAN;
--OUTPUT $action, inserted.*,deleted.*;  --this is for QA checks / comment COMMIT and use this instead to check data
--ROLLBACK TRAN;						-- rollback to start in case we don't like the resulting operrations
GO
