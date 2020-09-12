import QtQuick 2.2
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.4
import Qt.labs.settings 1.0

Page {
    id: page
    anchors.fill: parent
    title: (addQSO || liveQSO) ? qsTr("Add QSO") : qsTr("Edit QSO")
    anchors.margins: 5

    property bool addQSO: true;
    property bool liveQSO: false;
    property bool updateQSO: false;

    property int rid;

    property alias date: dateTextField.text;
    property alias time: timeTextField.text;
    property alias call: callTextField.text;
    property alias mode: modeComboBox.currentText;
    property alias freq: freqTextField.text
    property alias sent: sentTextField.text;
    property alias recv: recvTextField.text;
    property alias name: nameTextField.text;
    property alias ctry: ctryTextField.text;
    property alias grid: gridTextField.text;
    property alias qqth: qqthTextField.text;
    property alias comm: commTextField.text;
    property alias ctss: ctssTextField.text;
    property alias ctsr: ctsrTextField.text;

    property int sync

    property bool qrzFound: false;

    function reset() {
        callTextField.text = ""
        nameTextField.text = ""
        ctryTextField.text = ""
        dateTextField.text = ""
        timeTextField.text = ""
        freqTextField.text = (liveQSO && settings.cqActive) ? settings.cqFreq : ""
        // TODO: modeComboBox.
        sentTextField.text = ""
        recvTextField.text = ""
        gridTextField.text = ""
        qqthTextField.text = ""
        commTextField.text = ""
        ctssTextField.text = ""
        ctsrTextField.text = ""
        statusIndicator.Material.accent = Material.Green
    }

    Timer {
        id: rigTimer
        interval: 1000
        repeat: liveQSO && settings.rigActive
        running: liveQSO && settings.rigActive
        triggeredOnStart: liveQSO && settings.rigActive
        onTriggered: {
            rig.getFrequency(settings.rigHost, settings.rigPort)
            rig.getMode(settings.rigHost, settings.rigPort)
        }
    }

    Connections{
        target: rig

        onFreqDone: {
            freqTextField.text = freq
        }

        onModeDone: {
            var m
            if(mode == "USB" || mode == "LSB") {
                m = "SSB"
            } else {
                m = mode
            }
            var i = modeComboBox.find(m);
            modeComboBox.currentIndex = i;
        }
    }

    Connections{
        target: qrz
        onQrzDone: {
            if (nameTextField.text.length == 0) {
                nameTextField.text = fname + " " + name
            }
            if (ctryTextField.text.length == 0) {
                ctryTextField.text = country
            }
            if (gridTextField.text.length == 0) {
                gridTextField.text = locator
            }
            if (qqthTextField.text.length == 0) {
                qqthTextField.text = addr2
            }

            page.qrzFound = true
        }

        onQrzFail: {
            if(error == "Session Timeout") {
                qrz.receiveKey();
                qrz.lookupCall(callTextField.text);
            } else {
                page.qrzFound = false
            }
        }
    }

    ScrollView {
        anchors.fill: parent

        ButtonGroup {
            buttons: grid.children
        }

        GridLayout {
            id: grid
            columns: 4
            width: page.width // Important

            Label {
                id: dateLable
                text: qsTr("Date") + ":"
            }

            QSOTextField {
                id: dateTextField
                text: ""
                placeholderText: "DD.MM.YYYY"
                KeyNavigation.tab: timeTextField

                Timer {
                    id: dateTextTimer
                    interval: 1000
                    repeat: liveQSO
                    running: liveQSO
                    triggeredOnStart: liveQSO
                    onTriggered: {
                        var now = new Date();
                        var utc = new Date(now.getTime() + now.getTimezoneOffset() * 60000);
                        dateTextField.text = Qt.formatDateTime(utc, "dd.MM.yyyy");
                    }
                }
            }

            Label {
                id: timeLable
                text: qsTr("Time") + ":"
            }

            QSOTextField {
                id: timeTextField
                text: ""
                placeholderText: "00:00"
                KeyNavigation.tab: callTextField

                Timer {
                    id: timeTextTimer
                    interval: 1000
                    repeat: liveQSO
                    running: liveQSO
                    triggeredOnStart: liveQSO
                    onTriggered: {
                        var now = new Date();
                        var utc = new Date(now.getTime() + now.getTimezoneOffset() * 60000);
                        timeTextField.text = Qt.formatDateTime(utc, "HH:mm");
                    }
                }
            }

            Label {
                id: callSignLable
                text: qsTr("Callsign") + ":"
            }

            RowLayout {
                Layout.columnSpan: 3

                QSOTextField {
                    id: callTextField
                    text: ""
                    KeyNavigation.tab: modeComboBox
                    font.capitalization: Font.AllUppercase
                    inputMethodHints: Qt.ImhUppercaseOnly

                    onEditingFinished: {
                        if(settings.qrzActive) {
                            qrz.lookupCall(callTextField.text)
                        }

                        if(settings.contestActive) {
                            if(qsoModel.checkCall(callTextField.text)) {
                                statusIndicator.Material.accent = Material.Red
                            } else {
                                statusIndicator.Material.accent = Material.Green
                            }

                        }
                    }
                }

                IconButton {
                    id: statusIndicator
                    visible: settings.contestActive
                    enabled: settings.contestActive
                    width: height
                    Layout.preferredWidth: height
                    font.family: fontAwesome.name
                    buttonIcon: "\uf01e"
                    text: ""
                    highlighted: true
                    Material.theme:  Material.Light
                    Material.accent: Material.Green
                    padding: 0

                    onClicked: {
                        // TODO show previous contacts...
                        var tmp = ctssTextField.text;
                        page.reset();
                        if(settings.contestActive) {
                            ctssTextField.text = tmp;
                            sentTextField.text = 59;
                            recvTextField.text = 59;
                        }
                    }
                }

                IconButton {
                    id: qrzButton
                    width: height
                    Layout.preferredWidth: height
                    font.family: fontAwesome.name
                    buttonIcon: "\uf7a2"
                    text: ""
                    highlighted: qrzFound
                    Material.theme:  Material.Light
                    Material.accent: Material.Green
                    enabled: settings.qrzActive
                    padding: 0

                    onClicked: {
                        stackView.push("QRZView.qml",
                                   {
                                       "call" : callTextField.text
                                   });
                    }
                }

            }

            Label {
                id: modeLable
                text: qsTr("Mode") + ":"
            }

            ComboBox {
                id: modeComboBox
                Layout.columnSpan: 3
                Layout.fillWidth: true
                KeyNavigation.tab: freqTextField
                model: [
                    "SSB",
                    "FM",
                    "AM",
                    "CW",
                    "DSTAR",
                    "C4FM",
                    "DMR",
                    "DIGITALVOICE",
                    "PSK31",
                    "PSK63",
                    "RTTY",
                    "JT65",
                    "JT65B",
                    "JT6C",
                    "JT9-1",
                    "JT9",
                    "FT4",
                    "FT8",
                    "JS8",
                    "FSK441",
                    "JTMS",
                    "ISCAT",
                    "MSK144",
                    "JTMSK",
                    "QRA64",
                    "PKT",
                    "SSTV",
                    "HELL",
                    "HELL80",
                    "MFSK16",
                    "JT6M",
                    "ROS"
                ]
            }

            Label {
                id: freqLable
                text: qsTr("Frequency") + ":"
            }

            QSOTextField {
                id: freqTextField
                Layout.columnSpan: 3
                text: (liveQSO && settings.cqActive) ? settings.cqFreq : ""
                KeyNavigation.tab: sentTextField
                inputMethodHints: Qt.ImhFormattedNumbersOnly

                onEditingFinished: {
                    freqTextField.text = freqTextField.text.replace(",", ".");
                }
            }

            Label {
                id: sentLable
                text: "RST (S):"
            }

            QSOTextField {
                id: sentTextField
                text: settings.contestActive ? "59" : ""
                placeholderText: "59"
                KeyNavigation.tab: recvTextField
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Label {
                id: recvLable
                text: "RST (R):"
            }

            QSOTextField {
                id: recvTextField
                text: settings.contestActive ? "59" : ""
                placeholderText: "59"
                KeyNavigation.tab: settings.contestActive ? ctssTextField : nameTextField
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Label {
                id: ctssLable
                text: "Contest (S):"
                visible: settings.contestActive || ctssTextField.text || ctsrTextField.text
            }

            QSOTextField {
                id: ctssTextField
                text: ""
                KeyNavigation.tab: ctsrTextField
                visible: settings.contestActive || ctssTextField.text || ctsrTextField.text
            }

            Label {
                id: ctsrLable
                text: "Contest (R):"
                visible: settings.contestActive || ctsrTextField.text || ctssTextField.text
            }

            QSOTextField {
                id: ctsrTextField
                text: ""
                KeyNavigation.tab: nameTextField
                visible: settings.contestActive || ctsrTextField.text || ctssTextField.text
            }

            Label {
                id: nameLable
                text: qsTr("Name") + ":"
            }

            QSOTextField {
                id: nameTextField
                Layout.columnSpan: 3
                text: ""
                KeyNavigation.tab: qqthTextField
            }

            Label {
                id: qqthLable
                text: qsTr("QTH") + ":"
            }

            QSOTextField {
                id: qqthTextField
                Layout.columnSpan: 3
                text: ""
                KeyNavigation.tab: gridTextField
            }

            Label {
                id: ctryLable
                text: qsTr("Country") + ":"
            }

            QSOTextField {
                id: ctryTextField
                Layout.columnSpan: 3
                text: ""
                KeyNavigation.tab: gridTextField
            }

            Label {
                id: gridLable
                text: qsTr("Locator") + ":"
            }

            QSOTextField {
                id: gridTextField
                Layout.columnSpan: 3
                text: ""
                KeyNavigation.tab: commTextField
            }

            Label {
                id: commLable
                text: qsTr("Comment") + ":"
            }

            QSOTextField {
                id: commTextField
                Layout.columnSpan: 3
                text: ""
                KeyNavigation.tab: saveButton
            }

            Button {
                id: resetButton
                text: qsTr("Reset")
                visible: (addQSO || liveQSO)

                onClicked: {
                    var tmp = ctssTextField.text;
                    page.reset();
                    if(settings.contestActive) {
                        ctssTextField.text = tmp;
                        sentTextField.text = 59;
                        recvTextField.text = 59;
                    }
                }
            }

            Label {
                id: resetButtonPlaceHolder
                text: ""
                visible: updateQSO
            }

            Button {
                id: saveButton
                Layout.columnSpan: 3
                text: qsTr("Save QSO")
                Layout.fillWidth: true
                highlighted: true
                Material.theme: Material.Light
                Material.accent: Material.Green

                onClicked: {
                    if(addQSO == true || liveQSO == true) {
                        qsoModel.addQSO(callTextField.text,
                                nameTextField.text,
                                ctryTextField.text,
                                dateTextField.text,
                                timeTextField.text,
                                freqTextField.text,
                                modeComboBox.currentText,
                                sentTextField.text,
                                recvTextField.text,
                                gridTextField.text,
                                qqthTextField.text,
                                commTextField.text,
                                ctssTextField.text,
                                ctsrTextField.text
                                );

                        if(addQSO) {
                            stackView.pop()
                        } else if(liveQSO) {
                            var tmp = ctssTextField.text;
                            page.reset();
                            if(settings.contestActive && liveQSO) {
                                if(isNaN(tmp)) { // If it is e.g. a province
                                    ctssTextField.text = tmp;
                                } else { // if its a running number
                                    var contestNumber = parseInt(tmp);
                                    contestNumber += 1;
                                    ctssTextField.text = contestNumber;
                                    settings.contestNumber = contestNumber;
                                }
                                sentTextField.text = 59;
                                recvTextField.text = 59;
                            }
                        }

                    } else if(updateQSO == true) {
                        qsoModel.updateQSO(rid,
                                   callTextField.text,
                                   nameTextField.text,
                                   ctryTextField.text,
                                   dateTextField.text,
                                   timeTextField.text,
                                   freqTextField.text,
                                   modeComboBox.currentText,
                                   sentTextField.text,
                                   recvTextField.text,
                                   gridTextField.text,
                                   qqthTextField.text,
                                   commTextField.text,
                                   ctssTextField.text,
                                   ctsrTextField.text
                                   );
                        stackView.pop()
                    }
                }
            }
        }
    }
}
