import Quickshell
import Quickshell.Io

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
