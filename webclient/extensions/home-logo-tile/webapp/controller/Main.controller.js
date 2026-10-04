sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/format/DateFormat"
], function (Controller, DateFormat) {
    "use strict";

    return Controller.extend("fiorri.homelogo.controller.Main", {
        // Resolve paths from config.json relative to this app, wherever the Web Client serves it from.
        resolveAsset: function (sPath) {
            return sPath ? sap.ui.require.toUrl("fiorri/homelogo/" + sPath) : "";
        },

        today: function () {
            return DateFormat.getDateInstance({ style: "full" }).format(new Date());
        }
    });
});
