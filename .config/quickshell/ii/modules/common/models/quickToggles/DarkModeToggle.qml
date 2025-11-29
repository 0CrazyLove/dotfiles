import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.tr("Dark Mode")
    statusText: Translation.tr("Dark")
    toggled: true
    icon: "contrast"
    mainAction: () => {
        Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, "--mode", "dark", "--noswitch"]);
    }
    tooltipText: Translation.tr("Dark Mode")
}