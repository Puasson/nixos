pragma Singleton
import Quickshell
import QtQuick

// Estado del lanzador, espejo de IslandState: la vista (Dock.qml) y el
// servicio IPC (LauncherService.qml) se coordinan a través de aquí.
QtObject {
    id: root

    property bool isOpen: false
    property string query: ""
    property int selected: 0

    readonly property int maxResults: 60

    function open(): void {
        root.query = "";
        root.selected = 0;
        root.isOpen = true;
    }
    function close(): void {
        root.isOpen = false;
    }
    function toggle(): void {
        if (root.isOpen)
            root.close();
        else
            root.open();
    }

    function launch(entry): void {
        if (!entry)
            return;
        try {
            entry.execute();
        } catch (e) {}
        root.close();
    }

    property var allApps: DesktopEntries.applications.values.slice().sort(function(a, b) {
        return String(a.name).localeCompare(String(b.name));
    })

    // Tope de resultados: el Repeater solo instancia como máximo 60
    // delegados con IconImage en cada keystroke.
    property var filtered: {
        var q = root.query.trim().toLowerCase();
        var apps = root.allApps;
        if (q === "")
            return apps;
        var out = [];
        for (var i = 0; i < apps.length; i++) {
            var e = apps[i];
            var hay = (String(e.name || "") + " " + String(e.comment || "") + " " + String(e.id || e.desktopId || "")).toLowerCase();
            if (hay.indexOf(q) !== -1) {
                out.push(e);
                if (out.length >= root.maxResults)
                    break;
            }
        }
        return out;
    }

    // Vista recortada: con el panel colapsado el modelo se vacía y los
    // delegados se destruyen (sin IconImages en memoria en idle).
    property var visibleResults: {
        if (!root.isOpen)
            return [];
        var f = root.filtered;
        if (f.length > root.maxResults)
            return f.slice(0, root.maxResults);
        return f;
    }
}
