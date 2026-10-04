# אריח "דף הבית של החברה" עם הלוגו

ב-Web Client אין הגדרה מובנית להחלפת הלוגו בכותרת. האפליקציה הזו היא אריח בדף הבית שנפתח למסך ממותג:
לוגו החברה, שם, משפט פתיחה, תאריך וקישורים מהירים.

## התאמה

1. מחליפים את `webapp/img/logo.svg` בלוגו האמיתי (SVG או PNG). אם שם הקובץ משתנה, מעדכנים את `logo` ב-`webapp/config.json`.
2. ב-`webapp/config.json` מעדכנים את שם החברה, משפט הפתיחה והקישורים.

## תצוגה מקדימה מקומית

```bash
cd webclient/extensions/home-logo-tile/webapp
python3 -m http.server 8080
# לפתוח http://localhost:8080/index.html
```

## אריזה והתקנה ב-Web Client

האריזה נעשית עם הכלי הרשמי של SAP, ה-VS Code Wizard ל-Web Client Extensions:

1. ב-VS Code: מתקינים את הרחבת **SAP Business One Web Client Extension** (מקבלים אותה מ-SAP / השותף).
2. יוצרים פרויקט חדש: Application Type = **Tile Extension**, Module Type = **UI5 / Fiori App**.
3. מעתיקים את תוכן התיקייה `webapp` לתיקיית ה-`webapp` שהאשף יצר (דורסים את Component.js, manifest.json, view, controller).
   אם האשף נתן `sap.app.id` אחר, מחליפים את `fiorri.homelogo` בכל הקבצים ל-id שלו.
4. Build ← נוצר קובץ `.mtar`.
5. **Extension Manager** ← Import ← בחירת ה-`.mtar` ← Assign לחברה.
6. ב-Web Client: Edit Home Page ← App Finder ← הוספת האריח "FIORRI" לקבוצה הראשונה בדף הבית.

מקורות: [VS Code Wizard for Web Client Extensions](https://community.sap.com/t5/enterprise-resource-planning-blog-posts-by-sap/vs-code-wizard-for-sap-business-one-web-client-extensions/ba-p/13496294),
[Deploying Web Client Extensions on Extension Manager](https://learning.sap.com/courses/developing-ui-api-extensions-for-sap-business-one-web-client/deploying-sap-business-one-web-client-extensions-on-sap-business-one-extension-manager).
