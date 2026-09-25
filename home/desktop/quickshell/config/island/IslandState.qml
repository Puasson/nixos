pragma Singleton
import Quickshell
import QtQuick

QtObject {
    id: root

    property bool manualExpanded: false

    property string currentView: "music"

    property string notifTitle: ""
    property string notifBody: ""
    property string notifTime: ""
    property bool notifUnread: false

    function toggleExpanded(): void {
        root.manualExpanded = !root.manualExpanded;
    }

    function expand(): void {
        root.manualExpanded = true;
    }

    function collapse(): void {
        root.manualExpanded = false;
    }

    function setView(view): void {
        var v = String(view);
        if (v !== "music" && v !== "notif" && v !== "network" && v !== "sysmon" && v !== "calendar")
            return;
        root.currentView = v;
        if (v === "notif")
            root.notifUnread = false;
    }

    function pushNotification(title, body): void {
        root.notifTitle = String(title);
        root.notifBody = String(body);
        var now = new Date();
        var hh = String(now.getHours()).padStart(2, "0");
        var mm = String(now.getMinutes()).padStart(2, "0");
        root.notifTime = hh + ":" + mm;
        root.notifUnread = true;
    }

    function dismissNotification(): void {
        root.notifUnread = false;
    }

    function clearNotification(): void {
        root.notifTitle = "";
        root.notifBody = "";
        root.notifTime = "";
        root.notifUnread = false;
    }
}
