import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Servicio único (una instancia global): captura notificaciones
// vía NotificationServer y las publica en IslandState.
// No se instancia por pantalla: se crea una sola vez en shell.qml.
Scope {
    id: root

    NotificationServer {
        id: server
        actionsSupported: false
        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: false

        onNotification: n => {
            n.tracked = true;
            try {
                IslandState.pushNotification(String(n.summary || "Notificación"), String(n.body || ""));
            } catch (e) {}
        }
    }

    // IPC único (aquí y no en Island.qml: Island se instancia
    // por pantalla y el handler se duplicaría con varios monitores).
    // Uso: qs ipc call Island toggle|expand|collapse|view <music|notif|network|sysmon|calendar>
    IpcHandler {
        target: "Island"
        function toggle(): void {
            IslandState.toggleExpanded();
        }
        function expand(): void {
            IslandState.expand();
        }
        function collapse(): void {
            IslandState.collapse();
        }
        function view(name: string): void {
            IslandState.setView(name);
        }
    }
}
