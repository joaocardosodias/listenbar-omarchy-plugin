import "Model.js" as Model
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    readonly property bool showCover: setting("showCover", true) !== false
    readonly property bool showArtist: setting("showArtist", true) !== false
    readonly property bool showTime: setting("showTime", true) !== false
    readonly property bool showProgress: setting("showProgress", true) !== false
    readonly property bool showControls: setting("showControls", true) !== false
    readonly property bool hideWhenIdle: setting("hideWhenIdle", true) !== false
    readonly property real maxTitleWidth: Math.max(Style.space(80), Style.space(Number(setting("maxTitleWidth", 190))))
    readonly property string playerPreference: String(setting("playerPreference", "Automático"))
    readonly property var players: Mpris.players ? Mpris.players.values : []
    readonly property var sourcePlayers: Model.usablePlayers(players)
    property string selectedPlayerKey: ""
    readonly property var selectedPlayer: Model.findByKey(players, selectedPlayerKey)
    readonly property var activePlayer: selectedPlayer || Model.selectPlayer(players, playerPreference)
    readonly property bool live: activePlayer !== null && activePlayer !== undefined
    readonly property bool playing: live && activePlayer.isPlaying === true
    readonly property string title: live ? String(activePlayer.trackTitle || "") : ""
    readonly property string artist: live ? String(activePlayer.trackArtist || "") : ""
    readonly property string album: live ? String(activePlayer.trackAlbum || "") : ""
    readonly property string artUrl: live ? String(activePlayer.trackArtUrl || "") : ""
    readonly property string label: Model.trackLabel(activePlayer, showArtist)
    readonly property string sourceLabel: Model.playerLabel(activePlayer)
    readonly property color foreground: bar ? bar.barForeground : Color.foreground
    readonly property color accent: playing ? Color.accent : Qt.darker(foreground, 1.35)
    readonly property real coverSize: Math.max(Style.space(22), Math.min(Style.space(28), barSize - Style.space(8)))
    property int positionTick: 0
    readonly property real trackLength: live && activePlayer.lengthSupported ? Math.max(0, activePlayer.length) : 0
    readonly property real trackPosition: {
        var tick = positionTick;
        if (!live || !activePlayer.positionSupported)
            return 0;

        var value = Math.max(0, activePlayer.position);
        return trackLength > 0 ? Math.min(value, trackLength) : value;
    }
    readonly property real progress: trackLength > 0 ? Math.max(0, Math.min(1, trackPosition / trackLength)) : 0
    property bool popupOpen: false

    function close() {
        popupOpen = false;
    }

    function playPause() {
        if (!live)
            return false;

        if (activePlayer.canTogglePlaying) {
            activePlayer.togglePlaying();
            return true;
        }
        if (playing && activePlayer.canPause) {
            activePlayer.pause();
            return true;
        }
        if (!playing && activePlayer.canPlay) {
            activePlayer.play();
            return true;
        }
        return false;
    }

    function previous() {
        if (!live || !activePlayer.canGoPrevious)
            return false;

        activePlayer.previous();
        return true;
    }

    function next() {
        if (!live || !activePlayer.canGoNext)
            return false;

        activePlayer.next();
        return true;
    }

    function seekTo(seconds) {
        if (!live || !activePlayer.canSeek || !activePlayer.positionSupported || trackLength <= 0)
            return false;

        activePlayer.position = Math.max(0, Math.min(trackLength, seconds));
        return true;
    }

    function choosePlayer(player) {
        selectedPlayerKey = Model.playerKey(player);
    }

    function tooltip() {
        if (!live)
            return "Listenbar — nenhuma mídia";

        var prefix = playing ? "" : "Pausado — ";
        return prefix + (label || sourceLabel) + "\n" + sourceLabel;
    }

    moduleName: "io.github.joaocardosodias.listenbar"
    visible: live || !hideWhenIdle
    implicitWidth: !visible ? 0 : (vertical ? barSize : horizontalContent.implicitWidth + Style.space(12))
    implicitHeight: !visible ? 0 : (vertical ? verticalContent.implicitHeight + Style.space(8) : barSize)

    Timer {
        interval: 1000
        running: root.live
        repeat: true
        onTriggered: root.positionTick++
    }

    Row {
        id: horizontalContent

        visible: !root.vertical
        anchors.centerIn: parent
        spacing: Style.space(6)

        Item {
            id: coverFrame

            visible: root.showCover
            width: visible ? root.coverSize : 0
            height: root.coverSize
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: Style.spacing.labelGap
                color: Style.normalFillFor(root.foreground, root.accent)
                clip: true

                Image {
                    id: barCover

                    anchors.fill: parent
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                }

                Text {
                    anchors.centerIn: parent
                    visible: barCover.status !== Image.Ready
                    text: Model.playerGlyph(root.activePlayer)
                    color: root.accent
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.iconLarge
                }

            }

        }

        Item {
            id: labelClip

            visible: root.label !== ""
            width: visible ? Math.min(root.maxTitleWidth, labelText.implicitWidth) : 0
            height: Math.max(labelText.implicitHeight, Style.space(18))
            clip: true
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: labelText

                property real panOffset: 0
                readonly property real overflow: Math.max(0, implicitWidth - labelClip.width)

                anchors.verticalCenter: parent.verticalCenter
                x: -panOffset
                text: root.label
                textFormat: Text.PlainText
                color: root.foreground
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.body
                onTextChanged: panOffset = 0
            }

            SequentialAnimation {
                running: labelText.overflow > 0 && labelClip.visible && !root.popupOpen
                loops: Animation.Infinite

                PauseAnimation {
                    duration: 2200
                }

                NumberAnimation {
                    target: labelText
                    property: "panOffset"
                    from: 0
                    to: labelText.overflow
                    duration: Math.max(1400, labelText.overflow * 38)
                    easing.type: Easing.InOutQuad
                }

                PauseAnimation {
                    duration: 1800
                }

                NumberAnimation {
                    target: labelText
                    property: "panOffset"
                    from: labelText.overflow
                    to: 0
                    duration: Math.max(900, labelText.overflow * 24)
                    easing.type: Easing.InOutQuad
                }

            }

        }

        Text {
            visible: root.showTime && root.live && root.trackLength > 0
            anchors.verticalCenter: parent.verticalCenter
            text: Model.formatTime(root.trackPosition) + " / " + Model.formatTime(root.trackLength)
            textFormat: Text.PlainText
            color: Qt.darker(root.foreground, 1.35)
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.caption
            font.features: {
                "tnum": 1
            }
        }

        Row {
            visible: root.showControls && root.live
            spacing: 0
            anchors.verticalCenter: parent.verticalCenter

            TransportButton {
                iconText: "󰒮"
                foreground: root.foreground
                accent: root.accent
                enabled: root.live && root.activePlayer.canGoPrevious
                onClicked: root.previous()
            }

            TransportButton {
                iconText: root.playing ? "󰏤" : "󰐊"
                foreground: root.foreground
                accent: root.accent
                enabled: root.live && (root.activePlayer.canTogglePlaying || root.activePlayer.canPlay || root.activePlayer.canPause)
                onClicked: root.playPause()
            }

            TransportButton {
                iconText: "󰒭"
                foreground: root.foreground
                accent: root.accent
                enabled: root.live && root.activePlayer.canGoNext
                onClicked: root.next()
            }

        }

    }

    Column {
        id: verticalContent

        visible: root.vertical
        anchors.centerIn: parent
        spacing: Style.space(2)

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Model.playerGlyph(root.activePlayer)
            color: root.accent
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.iconLarge
        }

        TransportButton {
            visible: root.showControls && root.live
            anchors.horizontalCenter: parent.horizontalCenter
            buttonSize: Style.space(22)
            iconText: root.playing ? "󰏤" : "󰐊"
            foreground: root.foreground
            accent: root.accent
            enabled: root.live && (root.activePlayer.canTogglePlaying || root.activePlayer.canPlay || root.activePlayer.canPause)
            onClicked: root.playPause()
        }

    }

    Rectangle {
        visible: root.showProgress && root.live && root.trackLength > 0 && !root.vertical
        x: Style.space(6)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.space(2)
        width: Math.max(0, (root.width - Style.space(12)) * root.progress)
        height: Math.max(1, Style.space(2))
        radius: height / 2
        color: root.accent
        opacity: root.playing ? 0.95 : 0.5
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: root.live ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton)
                root.popupOpen = !root.popupOpen;
            else
                root.playPause();
        }
        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0)
                root.previous();
            else if (wheel.angleDelta.y < 0)
                root.next();
        }
        onEntered: {
            if (root.bar) {
                root.bar.showTooltip(root, root.tooltip());
            }
        }
        onExited: {
            if (root.bar) {
                root.bar.hideTooltip(root);
            }
        }
    }

    PopupCard {
        id: popup

        anchorItem: root
        bar: root.bar
        owner: root
        open: root.popupOpen
        contentWidth: fittedContentWidth(Style.space(340))
        contentHeight: fittedContentHeight(popupContent.implicitHeight)

        Column {
            id: popupContent

            anchors.fill: parent
            spacing: Style.space(12)

            Row {
                width: parent.width
                spacing: Style.space(12)

                Rectangle {
                    width: Style.space(86)
                    height: width
                    radius: Style.cornerRadius
                    color: Style.normalFillFor(root.foreground, root.accent)
                    clip: true

                    Image {
                        id: popupCover

                        anchors.fill: parent
                        source: root.artUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: popupCover.status !== Image.Ready
                        text: Model.playerGlyph(root.activePlayer)
                        color: root.accent
                        font.family: root.bar ? root.bar.fontFamily : Style.font.family
                        font.pixelSize: Style.font.displayLarge
                    }

                }

                Column {
                    width: parent.width - Style.space(98)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.space(4)

                    Text {
                        width: parent.width
                        text: root.title || "Nada tocando"
                        textFormat: Text.PlainText
                        color: root.foreground
                        font.family: root.bar ? root.bar.fontFamily : Style.font.family
                        font.pixelSize: Style.font.subtitle
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: text !== ""
                        width: parent.width
                        text: root.artist
                        textFormat: Text.PlainText
                        color: Qt.darker(root.foreground, 1.25)
                        font.family: root.bar ? root.bar.fontFamily : Style.font.family
                        font.pixelSize: Style.font.body
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: text !== ""
                        width: parent.width
                        text: root.album
                        textFormat: Text.PlainText
                        color: Qt.darker(root.foreground, 1.55)
                        font.family: root.bar ? root.bar.fontFamily : Style.font.family
                        font.pixelSize: Style.font.caption
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: root.sourceLabel
                        textFormat: Text.PlainText
                        color: root.accent
                        font.family: root.bar ? root.bar.fontFamily : Style.font.family
                        font.pixelSize: Style.font.caption
                        elide: Text.ElideRight
                    }

                }

            }

            Item {
                visible: root.live && root.trackLength > 0
                width: parent.width
                height: Style.space(18)

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: Math.max(Style.space(3), 3)
                    radius: height / 2
                    color: Qt.darker(root.foreground, 1.9)

                    Rectangle {
                        width: parent.width * root.progress
                        height: parent.height
                        radius: parent.radius
                        color: root.accent
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.live && root.activePlayer.canSeek
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onPressed: function(mouse) {
                        root.seekTo((mouse.x / width) * root.trackLength);
                    }
                    onPositionChanged: function(mouse) {
                        if (pressed)
                            root.seekTo((mouse.x / width) * root.trackLength);

                    }
                }

            }

            Row {
                visible: root.live && root.trackLength > 0
                width: parent.width

                Text {
                    id: elapsedLabel

                    text: Model.formatTime(root.trackPosition)
                    color: Qt.darker(root.foreground, 1.35)
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.caption
                }

                Item {
                    width: parent.width - elapsedLabel.implicitWidth - durationLabel.implicitWidth
                    height: 1
                }

                Text {
                    id: durationLabel

                    text: Model.formatTime(root.trackLength)
                    color: Qt.darker(root.foreground, 1.35)
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.caption
                }

            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Style.space(8)

                Button {
                    iconText: "󰒮"
                    foreground: root.foreground
                    enabled: root.live && root.activePlayer.canGoPrevious
                    opacity: enabled ? 1 : 0.35
                    onClicked: root.previous()
                }

                Button {
                    iconText: root.playing ? "󰏤" : "󰐊"
                    foreground: root.foreground
                    iconSize: Style.font.iconLarge
                    horizontalPadding: Style.spacing.panelGap
                    enabled: root.live && (root.activePlayer.canTogglePlaying || root.activePlayer.canPlay || root.activePlayer.canPause)
                    opacity: enabled ? 1 : 0.35
                    onClicked: root.playPause()
                }

                Button {
                    iconText: "󰒭"
                    foreground: root.foreground
                    enabled: root.live && root.activePlayer.canGoNext
                    opacity: enabled ? 1 : 0.35
                    onClicked: root.next()
                }

            }

            Column {
                visible: root.sourcePlayers.length > 1
                width: parent.width
                spacing: Style.space(4)

                Text {
                    text: "PLAYERS"
                    color: Qt.darker(root.foreground, 1.5)
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.caption
                    font.bold: true
                }

                Repeater {
                    model: root.sourcePlayers

                    delegate: Button {
                        required property var modelData

                        width: parent.width
                        text: Model.playerLabel(modelData) + (modelData.isPlaying ? "  •  tocando" : "")
                        iconText: Model.playerGlyph(modelData)
                        foreground: root.foreground
                        active: Model.playerKey(modelData) === Model.playerKey(root.activePlayer)
                        leftAlign: true
                        onClicked: root.choosePlayer(modelData)
                    }

                }

            }

        }

    }

}
