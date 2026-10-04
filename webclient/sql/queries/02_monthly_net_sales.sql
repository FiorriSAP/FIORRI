-- FIORRI KPI 02: מכירות נטו לפי חודש, 12 חודשים אחרונים (חשבוניות פחות זיכויים, ללא מע"מ)
SELECT
    FORMAT(X.DocDate, 'yyyy-MM')   AS [חודש],
    SUM(X.NetAmount)               AS [מכירות נטו],
    COUNT(DISTINCT X.CardCode)     AS [לקוחות פעילים]
FROM (
    SELECT DocDate, CardCode, DocTotal - VatSum AS NetAmount
    FROM OINV
    WHERE CANCELED = 'N'
      AND DocDate >= DATEADD(MONTH, -11, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
    UNION ALL
    SELECT DocDate, CardCode, -(DocTotal - VatSum)
    FROM ORIN
    WHERE CANCELED = 'N'
      AND DocDate >= DATEADD(MONTH, -11, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
) X
GROUP BY FORMAT(X.DocDate, 'yyyy-MM')
