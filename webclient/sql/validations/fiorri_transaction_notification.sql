-- FIORRI: ולידציות שמירה ל-SAP Business One (MS SQL Server)
--
-- איך מתקינים:
--   1. גיבוי של מסד החברה.
--   2. ב-SSMS: פתיחת הפרוצדורה dbo.SBO_SP_TransactionNotification במסד החברה (Modify).
--   3. הדבקת הבלוק שבין BEGIN FIORRI ל-END FIORRI אחרי השורה "-- ADD YOUR CODE HERE"
--      ולפני "select @error, @error_message" שבסוף הפרוצדורה.
--   4. הפעלה (Execute) ובדיקה על חברת בדיקות לפני ייצור.
--
-- הבדיקות חלות גם על הקליינט השולחני, גם על ה-Web Client וגם על Service Layer / DI API.
-- כל בדיקה מסומנת בדגל ON/OFF בתחילת הבלוק, כך שאפשר לכבות בלי למחוק קוד.
--
-- מסגרת אשראי: לא כאן. השתמשו בבדיקה המובנית:
--   Administration > System Initialization > Document Settings > General > "Activate Credit Limit / Commitment Limit"
--   או בתנאי "Deviation from Credit Line" ב-Approval Templates.

-- ==================== BEGIN FIORRI ====================
DECLARE @fiorri_require_slp      BIT = 1;  -- איש מכירות חובה בהצעת מחיר, הזמנה וחשבונית
DECLARE @fiorri_require_numatcard BIT = 1; -- אסמכתת לקוח חובה בהזמנת לקוח
DECLARE @fiorri_block_zero_price BIT = 1;  -- חסימת שורה במחיר 0 בהזמנה וחשבונית (לפריטים שאינם טקסט)

-- 23 = Sales Quotation, 17 = Sales Order, 13 = A/R Invoice
IF @error = 0 AND @fiorri_require_slp = 1
   AND @object_type IN ('23', '17', '13') AND @transaction_type IN ('A', 'U')
BEGIN
    IF EXISTS (
        SELECT 1 FROM OQUT WHERE @object_type = '23' AND DocEntry = CAST(@list_of_cols_val_tab_del AS INT) AND SlpCode = -1
        UNION ALL
        SELECT 1 FROM ORDR WHERE @object_type = '17' AND DocEntry = CAST(@list_of_cols_val_tab_del AS INT) AND SlpCode = -1
        UNION ALL
        SELECT 1 FROM OINV WHERE @object_type = '13' AND DocEntry = CAST(@list_of_cols_val_tab_del AS INT) AND SlpCode = -1
    )
    BEGIN
        SET @error = 50101;
        SET @error_message = N'FIORRI: יש לבחור איש מכירות במסמך.';
    END
END

IF @error = 0 AND @fiorri_require_numatcard = 1
   AND @object_type = '17' AND @transaction_type IN ('A', 'U')
BEGIN
    IF EXISTS (
        SELECT 1 FROM ORDR
        WHERE DocEntry = CAST(@list_of_cols_val_tab_del AS INT)
          AND DocStatus = 'O'
          AND ISNULL(LTRIM(RTRIM(NumAtCard)), N'') = N''
    )
    BEGIN
        SET @error = 50102;
        SET @error_message = N'FIORRI: יש למלא אסמכתת לקוח (מס'' הזמנה של הלקוח) בהזמנת הלקוח.';
    END
END

IF @error = 0 AND @fiorri_block_zero_price = 1
   AND @object_type IN ('17', '13') AND @transaction_type = 'A'
BEGIN
    IF EXISTS (
        SELECT 1 FROM RDR1
        WHERE @object_type = '17' AND DocEntry = CAST(@list_of_cols_val_tab_del AS INT)
          AND ISNULL(ItemCode, N'') <> N'' AND Quantity > 0 AND Price = 0
        UNION ALL
        SELECT 1 FROM INV1
        WHERE @object_type = '13' AND DocEntry = CAST(@list_of_cols_val_tab_del AS INT)
          AND ISNULL(ItemCode, N'') <> N'' AND Quantity > 0 AND Price = 0
    )
    BEGIN
        SET @error = 50103;
        SET @error_message = N'FIORRI: קיימת שורת פריט במחיר 0. יש לעדכן מחיר או להסיר את השורה.';
    END
END
-- ===================== END FIORRI =====================
