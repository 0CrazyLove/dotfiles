import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import "./quickToggles/"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../../colors.qml" as Colors

Scope {
    id: root
    property int sidebarWidth: Appearance.sizes.sidebarWidth
    property int sidebarPadding: 12
    property string settingsQmlPath: Quickshell.shellPath("settings.qml")

    PanelWindow {
        id: sidebarRoot
        visible: GlobalStates.sidebarRightOpen

        function hide() {
            GlobalStates.sidebarRightOpen = false
        }

        exclusiveZone: 0
        implicitWidth: sidebarWidth
        WlrLayershell.namespace: "quickshell:sidebarRight"
        // Hyprland 0.49: Focus is always exclusive and setting this breaks mouse focus grab
        // WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        color: "transparent"

        anchors {
            top: true
            right: true
            bottom: true
        }

        HyprlandFocusGrab {
            id: grab
            windows: [ sidebarRoot ]
            active: GlobalStates.sidebarRightOpen
            onCleared: () => {
                if (!active) sidebarRoot.hide()
            }
        }

        Loader {
            id: sidebarContentLoader
            active: GlobalStates.sidebarRightOpen || Config?.options.sidebar.keepRightSidebarLoaded
            anchors {
                fill: parent
                margins: Appearance.sizes.hyprlandGapsOut
                leftMargin: Appearance.sizes.elevationMargin
            }
            width: sidebarWidth - Appearance.sizes.hyprlandGapsOut - Appearance.sizes.elevationMargin
            height: parent.height - Appearance.sizes.hyprlandGapsOut * 2

            focus: GlobalStates.sidebarRightOpen
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    sidebarRoot.hide();
                }
            }

            sourceComponent: Item {
                implicitHeight: sidebarRightBackground.implicitHeight
                implicitWidth: sidebarRightBackground.implicitWidth

                StyledRectangularShadow {
                    target: sidebarRightBackground
                }
                Rectangle {
                    id: sidebarRightBackground

                    anchors.fill: parent
                    implicitHeight: parent.height - Appearance.sizes.hyprlandGapsOut * 2
                    implicitWidth: sidebarWidth - Appearance.sizes.hyprlandGapsOut * 2
                    color: "#000000"
                    border.width: 1
                    border.color: "#303030"
                    radius: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: sidebarPadding
                        spacing: sidebarPadding

                        RowLayout {
                            Layout.fillHeight: false
                            spacing: 10
                            Layout.margins: 10
                            Layout.topMargin: 5
                            Layout.bottomMargin: 0

                            CustomIcon {
                                id: distroIcon
                                width: 25
                                height: 25
                                source: SystemInfo.distroIcon
                                colorize: true
                                color: "#F2F2F2"
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            ButtonGroup {
                                QuickToggleButton {
                                    toggled: false
                                    buttonIcon: "restart_alt"
                                    onClicked: {
                                        Hyprland.dispatch("reload")
                                        Quickshell.reload(true)
                                    }
                                    StyledToolTip {
                                        content: Translation.tr("Reload Hyprland & Quickshell")
                                    }
                                }
                               
                                QuickToggleButton {
                                    toggled: false
                                    buttonIcon: "power_settings_new"
                                    onClicked: {
                                        GlobalStates.sessionOpen = true
                                    }
                                    StyledToolTip {
                                        content: Translation.tr("Session")
                                    }
                                }
                            }
                        }

                        ButtonGroup {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 5
                            padding: 5
                            color: "#181818"

                            NetworkToggle {}
                            BluetoothToggle {}
                            NightLight {}
                            GameMode {}
                            IdleInhibitor {}
                            EasyEffectsToggle {}
                            CloudflareWarp {}
                        }

                        // Center widget group
                        CenterWidgetGroup {
                            focus: sidebarRoot.visible
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }

                        BottomWidgetGroup {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillHeight: false
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                        }
                    }
                }
            }
        }


    }

    IpcHandler {
        target: "sidebarRight"

        function toggle(): void {
            GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
            if(GlobalStates.sidebarRightOpen) Notifications.timeoutAll();
        }

        function close(): void {
            GlobalStates.sidebarRightOpen = false;
        }

        function open(): void {
            GlobalStates.sidebarRightOpen = true;
            Notifications.timeoutAll();
        }
    }

    GlobalShortcut {
        name: "sidebarRightToggle"
        description: "Toggles right sidebar on press"

        onPressed: {
            GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
            if(GlobalStates.sidebarRightOpen) Notifications.timeoutAll();
        }
    }
    GlobalShortcut {
        name: "sidebarRightOpen"
        description: "Opens right sidebar on press"

        onPressed: {
            GlobalStates.sidebarRightOpen = true;
            Notifications.timeoutAll();
        }
    }
    GlobalShortcut {
        name: "sidebarRightClose"
        description: "Closes right sidebar on press"

        onPressed: {
            GlobalStates.sidebarRightOpen = false;
        }
    }

}
