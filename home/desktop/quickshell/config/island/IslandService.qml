import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

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
