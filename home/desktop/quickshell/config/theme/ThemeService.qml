import Quickshell
import Quickshell.Io

// Servicio IPC del tema, espejo de LauncherService/IslandService:
// `qs ipc call Theme setFamily nord` / `setMode dark` / `toggleMode`.
Scope {
    IpcHandler {
        target: "Theme"

        function setFamily(fam: string): bool {
            return Theme.setFamily(fam);
        }
        function setMode(mode: string): bool {
            return Theme.setMode(mode);
        }
        function toggleMode(): bool {
            return Theme.toggleMode();
        }
        function nextFamily(): string {
            return Theme.nextFamily();
        }
        function status(): string {
            return Theme.family + " " + Theme.modeName();
        }
    }
}
