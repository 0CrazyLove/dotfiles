import QtQuick
import qs.modules.common

Rectangle {
    id: root
    radius: Appearance.rounding.normal
    color: "#181818" 

    signal openAudioOutputDialog()
    signal openAudioInputDialog()
    signal openBluetoothDialog()
    signal openNightLightDialog()
    signal openWifiDialog()
}
