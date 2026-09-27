import Quickshell
import Quickshell.Io

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
