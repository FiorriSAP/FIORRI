# SAP Business One Web Client: שדרוג והרחבות

סביבת יעד: SAP Business One 10.0 FP 2608, Microsoft SQL Server.

## שלב 1 (בתיקייה הזו)

| מה | איפה |
|---|---|
| מדריך הגדרה ל-Key User: דפי בית לפי תפקיד, Views, שאילתות, UDF/UDO, Theme, אישורים | [`docs/key-user-setup.md`](docs/key-user-setup.md) |
| 6 שאילתות KPI ל-User-Defined Queries (גיול, מכירות חודשיות, איחורי אספקה, חוסרי מלאי, חריגת אשראי, טופ לקוחות) | [`sql/queries`](sql/queries) |
| ולידציות שמירה (איש מכירות, אסמכתת לקוח, מחיר 0) | [`sql/validations`](sql/validations) |
| אריח דף בית עם לוגו החברה | [`extensions/home-logo-tile`](extensions/home-logo-tile) |

## השלבים הבאים

1. **UI API Extensions**: כפתור "צור מסמך המשך" בהזמנת לקוח, הזזת/הסתרת שדות בכרטיסי מסמך.
2. **ארכיון דיגיטלי**: צפייה במסמכים סרוקים מתוך כרטיס המסמך (מתחבר ל-`scripts/setup_digital_archive.ps1`).
3. **אפליקציית מחסן לנייד**: ליקוט, ספירה וקליטה עם ברקוד (UI5 + Service Layer).
4. **אישורים מהנייד** עם התראות במייל / Teams.
5. **פורטל לקוחות/ספקים** חיצוני מעל Service Layer.
