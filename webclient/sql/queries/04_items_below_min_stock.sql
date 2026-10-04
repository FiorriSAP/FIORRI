-- FIORRI KPI 04: פריטים מתחת למלאי מינימום לפי מחסן
-- זמין = במלאי - מוקצה + בהזמנה. משתמש במינימום ברמת מחסן (OITW.MinStock),
-- שמוגדר כשבכרטיס הפריט מסומן "Set Inventory Level by Warehouse".
SELECT
    T0.ItemCode                                         AS [מק"ט],
    T1.ItemName                                         AS [שם פריט],
    T2.ItmsGrpNam                                       AS [קבוצת פריט],
    T0.WhsCode                                          AS [מחסן],
    T0.OnHand                                           AS [במלאי],
    T0.IsCommited                                       AS [מוקצה],
    T0.OnOrder                                          AS [בהזמנה],
    T0.OnHand - T0.IsCommited + T0.OnOrder              AS [זמין],
    T0.MinStock                                         AS [מינימום],
    T0.MinStock - (T0.OnHand - T0.IsCommited + T0.OnOrder) AS [חוסר]
FROM OITW T0
INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
LEFT JOIN OITB T2 ON T1.ItmsGrpCod = T2.ItmsGrpCod
WHERE T1.InvntItem = 'Y'
  AND T1.frozenFor = 'N'
  AND T0.MinStock > 0
  AND T0.OnHand - T0.IsCommited + T0.OnOrder < T0.MinStock
