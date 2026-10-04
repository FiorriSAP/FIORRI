-- FIORRI KPI 03: שורות הזמנות לקוח פתוחות שתאריך האספקה שלהן עבר
SELECT
    T0.DocNum                                   AS [מס' הזמנה],
    T0.CardCode                                 AS [קוד לקוח],
    T0.CardName                                 AS [שם לקוח],
    T2.SlpName                                  AS [איש מכירות],
    T1.ItemCode                                 AS [מק"ט],
    T1.Dscription                               AS [תיאור],
    T1.OpenQty                                  AS [כמות פתוחה],
    T1.ShipDate                                 AS [תאריך אספקה],
    DATEDIFF(DAY, T1.ShipDate, GETDATE())       AS [ימי איחור],
    T1.OpenSum                                  AS [סכום פתוח]
FROM ORDR T0
INNER JOIN RDR1 T1 ON T0.DocEntry = T1.DocEntry
LEFT JOIN OSLP T2 ON T0.SlpCode = T2.SlpCode
WHERE T0.DocStatus = 'O'
  AND T0.CANCELED = 'N'
  AND T1.LineStatus = 'O'
  AND T1.ShipDate < CAST(GETDATE() AS DATE)
