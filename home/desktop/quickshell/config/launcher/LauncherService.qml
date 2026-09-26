import Quickshell
import Quickshell.Io

// Servicio IPC del lanzador, espejo de IslandService: Super+A
// (keybindings.lua) invoca "qs ipc call LauncherMenu toggle".
Scope {
    IpcHandler {
        target: "LauncherMenu"

        function toggle(): void {
            LauncherState.toggle();
        }
        function open(): void {
            LauncherState.open();
        }
        function close(): void {
            LauncherState.close();
        }
    }
}
