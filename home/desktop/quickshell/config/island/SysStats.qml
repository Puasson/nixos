pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property real cpuPct: 0
    property real memPct: 0
    property string memText: "—"

    property real netDown: 0
    property real netUp: 0

    property var cpuHist: []
    property var memHist: []
    property var netDownHist: []
    property var netUpHist: []
    property int histMax: 60

    property var _prevIdle: -1
    property var _prevTotal: -1
    property var _prevRx: -1
    property var _prevTx: -1

    property bool active: true

    function _push(prop, v): void {
        try {
            var h = root[prop].slice();
            h.push(v);
            while (h.length > root.histMax)
                h.shift();
            root[prop] = h;
        } catch (e) {}
    }

    function _parseStat(text): void {
        try {
            var lines = String(text).split("\n");
            if (lines.length === 0)
                return;
            var parts = lines[0].trim().split(/\s+/);
            if (parts.length < 5 || parts[0] !== "cpu")
                return;
            var nums = [];
            for (var i = 1; i < parts.length; i++)
                nums.push(parseFloat(parts[i]));
            var idle = nums[3] + (nums.length > 4 ? nums[4] : 0);
            var total = 0;
            for (var j = 0; j < nums.length; j++)
                total += nums[j];
            if (root._prevTotal >= 0 && total > root._prevTotal) {
                var dIdle = idle - root._prevIdle;
                var dTotal = total - root._prevTotal;
                if (dTotal > 0)
                    root.cpuPct = Math.max(0, Math.min(1, 1 - dIdle / dTotal));
            }
            root._prevIdle = idle;
            root._prevTotal = total;
            root._push("cpuHist", root.cpuPct);
        } catch (e) {}
    }

    function _parseMem(text): void {
        try {
            var total = -1;
            var avail = -1;
            var lines = String(text).split("\n");
            for (var i = 0; i < lines.length; i++) {
                var m = lines[i].match(/^(\w+):\s+(\d+)/);
                if (!m)
                    continue;
                if (m[1] === "MemTotal")
                    total = parseFloat(m[2]);
                else if (m[1] === "MemAvailable")
                    avail = parseFloat(m[2]);
            }
            if (total > 0 && avail >= 0) {
                root.memPct = Math.max(0, Math.min(1, (total - avail) / total));
                var usedMiB = Math.round((total - avail) / 1024);
                var totalMiB = Math.round(total / 1024);
                root.memText = usedMiB + " / " + totalMiB + " MiB";
                root._push("memHist", root.memPct);
            }
        } catch (e) {}
    }

    function _parseNet(text): void {
        try {
            var lines = String(text).split("\n");
            var rx = 0;
            var tx = 0;
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                var m = line.match(/^([A-Za-z0-9._-]+):\s*(.+)$/);
                if (!m)
                    continue;
                if (m[1] === "lo")
                    continue;
                var fields = m[2].trim().split(/\s+/);
                if (fields.length < 9)
                    continue;
                rx += parseFloat(fields[0]) || 0;
                tx += parseFloat(fields[8]) || 0;
            }
            if (root._prevRx >= 0) {
                var dt = Math.max(1, pollTimer.interval / 1000);
                root.netDown = Math.max(0, (rx - root._prevRx) / dt);
                root.netUp = Math.max(0, (tx - root._prevTx) / dt);
                root._push("netDownHist", root.netDown);
                root._push("netUpHist", root.netUp);
            }
            root._prevRx = rx;
            root._prevTx = tx;
        } catch (e) {}
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        printErrors: false
        onLoaded: root._parseStat(statFile.text())
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        printErrors: false
        onLoaded: root._parseMem(memFile.text())
    }

    FileView {
        id: netFile
        path: "/proc/net/dev"
        printErrors: false
        onLoaded: root._parseNet(netFile.text())
    }

    Timer {
        id: pollTimer
        interval: 2000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload();
            memFile.reload();
            netFile.reload();
        }
    }
}
