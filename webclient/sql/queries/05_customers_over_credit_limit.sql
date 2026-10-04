-- FIORRI KPI 05: לקוחות שהחשיפה שלהם (יתרה + הזמנות פתוחות + תעודות משלוח פתוחות) עוברת את מסגרת האשראי
SELECT
    T0.CardCode                                                AS [קוד לקוח],
    T0.CardName                                                AS [שם לקוח],
    T1.SlpName                                                 AS [איש מכירות],
    T0.CreditLine                                              AS [מסגרת אשראי],
    T0.Balance                                                 AS [יתרת חשבון],
    T0.OrdersBal                                               AS [הזמנות פתוחות],
    T0.DNotesBal                                               AS [משלוחים פתוחים],
    T0.Balance + T0.OrdersBal + T0.DNotesBal                   AS [חשיפה],
    T0.Balance + T0.OrdersBal + T0.DNotesBal - T0.CreditLine   AS [חריגה]
FROM OCRD T0
LEFT JOIN OSLP T1 ON T0.SlpCode = T1.SlpCode
WHERE T0.CardType = 'C'
  AND T0.frozenFor = 'N'
  AND T0.CreditLine > 0
  AND T0.Balance + T0.OrdersBal + T0.DNotesBal > T0.CreditLine
