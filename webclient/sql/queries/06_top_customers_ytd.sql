-- FIORRI KPI 06: 20 הלקוחות המובילים מתחילת השנה (מכירות נטו, ללא מע"מ)
SELECT TOP 20
    X.CardCode           AS [קוד לקוח],
    X.CardName           AS [שם לקוח],
    SUM(X.NetAmount)     AS [מכירות נטו מתחילת השנה],
    COUNT(*)             AS [מסמכים]
FROM (
    SELECT CardCode, CardName, DocTotal - VatSum AS NetAmount
    FROM OINV
    WHERE CANCELED = 'N' AND DocDate >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
    UNION ALL
    SELECT CardCode, CardName, -(DocTotal - VatSum)
    FROM ORIN
    WHERE CANCELED = 'N' AND DocDate >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
) X
GROUP BY X.CardCode, X.CardName
ORDER BY SUM(X.NetAmount) DESC
