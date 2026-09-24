pragma Singleton
import Quickshell
import QtQuick

QtObject {
    id: root

    property var edgeHovered: ({})
    property var dockHovered: ({})
    property int revision: 0

    function setEdgeHovered(screenName, hovered) {
        if (!screenName)
            return;
        if (!!root.edgeHovered[screenName] === !!hovered)
            return;
        var copy = Object.assign({}, root.edgeHovered);
        copy[screenName] = !!hovered;
        root.edgeHovered = copy;
        root.revision++;
    }

    function setDockHovered(screenName, hovered) {
        if (!screenName)
            return;
        if (!!root.dockHovered[screenName] === !!hovered)
            return;
        var copy = Object.assign({}, root.dockHovered);
        copy[screenName] = !!hovered;
        root.dockHovered = copy;
        root.revision++;
    }

    function shouldShow(screenName, windowCount) {
        var rev = root.revision;
        if (windowCount === 0)
            return true;
        return !!root.edgeHovered[screenName] || !!root.dockHovered[screenName];
    }
}
