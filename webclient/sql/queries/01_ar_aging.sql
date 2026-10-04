-- FIORRI KPI 01: גיול חובות לקוחות (חשבוניות פתוחות)
-- SAP Business One 10.0, MS SQL Server. ללא פרמטרים, כדי שתעבוד כ-List View ב-Web Client.
SELECT
    T0.CardCode                                  AS [קוד לקוח],
    T0.CardName                                  AS [שם לקוח],
    T1.SlpName                                   AS [איש מכירות],
    T0.DocNum                                    AS [מס' חשבונית],
    T0.DocDate                                   AS [תאריך],
    T0.DocDueDate                                AS [תאריך פירעון],
    DATEDIFF(DAY, T0.DocDueDate, GETDATE())      AS [ימי פיגור],
    T0.DocTotal - T0.PaidToDate                  AS [יתרה פתוחה],
    CASE
        WHEN DATEDIFF(DAY, T0.DocDueDate, GETDATE()) <= 0  THEN N'0. טרם הגיע מועד'
        WHEN DATEDIFF(DAY, T0.DocDueDate, GETDATE()) <= 30 THEN N'1. 1-30'
        WHEN DATEDIFF(DAY, T0.DocDueDate, GETDATE()) <= 60 THEN N'2. 31-60'
        WHEN DATEDIFF(DAY, T0.DocDueDate, GETDATE()) <= 90 THEN N'3. 61-90'
        ELSE N'4. 90+'
    END                                          AS [טווח גיול]
FROM OINV T0
LEFT JOIN OSLP T1 ON T0.SlpCode = T1.SlpCode
WHERE T0.DocStatus = 'O'
  AND T0.CANCELED = 'N'
