import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: win
    width: 680
    height: 740
    minimumWidth: 480
    minimumHeight: 520
    visible: true
    title: "OmaTools — PowerToys for Omarchy"

    // Theme properties passed by omatools launcher or fallback
    property string themeBackground: "#050c0b"
    property string themeForeground: "#cdf2e3"
    property string themeAccent: "#5dffb0"
    property string themeSelection: "#12352b"
    property string themeMuted: "#6f9a8c"
    property bool darkMode: true
    property string apiPort: ""

    function triggerAction(actionName) {
        if (!apiPort) return;
        let xhr = new XMLHttpRequest();
        xhr.open("POST", "http://127.0.0.1:" + apiPort + "/action/" + actionName);
        xhr.send();
    }

    Component.onCompleted: {
        let args = Qt.application.arguments;
        for (let i = 0; i < args.length; i++) {
            if (args[i] === "--" && i + 6 < args.length) {
                themeBackground = args[i + 1];
                themeForeground = args[i + 2];
                themeAccent = args[i + 3];
                themeSelection = args[i + 4];
                themeMuted = args[i + 5];
                darkMode = args[i + 6] === "true";
                if (i + 7 < args.length) {
                    apiPort = args[i + 7];
                }
                break;
            }
        }
    }

    function mixColors(base, tint, amount) {
        return Qt.rgba(
            base.r + (tint.r - base.r) * amount,
            base.g + (tint.g - base.g) * amount,
            base.b + (tint.b - base.b) * amount, 1);
    }

    readonly property color raisedColor: mixColors(Qt.color(themeBackground), Qt.color(themeForeground), 0.06)
    readonly property color cardBorderColor: mixColors(Qt.color(themeBackground), Qt.color(themeForeground), 0.12)
    readonly property color mutedTextColor: Qt.color(themeMuted)

    Material.theme: darkMode ? Material.Dark : Material.Light
    Material.accent: themeAccent
    color: themeBackground

    Shortcut {
        sequence: "Ctrl+Q"
        context: Qt.ApplicationShortcut
        onActivated: Qt.quit()
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        onActivated: Qt.quit()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        // Header (Omacom minimal aesthetic)
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Rectangle {
                width: 48
                height: 48
                radius: 12
                color: Qt.color(themeAccent)

                Text {
                    anchors.centerIn: parent
                    text: "🛠️"
                    font.pixelSize: 24
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "OmaTools"
                    font.pixelSize: 22
                    font.bold: true
                    color: themeForeground
                }
                Text {
                    text: "Suíte de Produtividade & Utilitários para Omarchy"
                    font.pixelSize: 13
                    color: mutedTextColor
                }
            }

            Item { Layout.fillWidth: true }

            Label {
                text: "v0.1.0 • Apache-2.0"
                font.pixelSize: 11
                color: mutedTextColor
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: cardBorderColor
        }

        // Section: Workspaces (Featured PowerToys Tool)
        Rectangle {
            Layout.fillWidth: true
            height: 110
            radius: 14
            color: raisedColor
            border.color: cardBorderColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "🪟 Workspaces (Snapshot & Restauração de Sessão)"
                        font.pixelSize: 15
                        font.bold: true
                        color: themeForeground
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "Hyprland IPC"
                        font.pixelSize: 11
                        color: themeAccent
                    }
                }

                Text {
                    text: "Salve o arranjo de janelas atual da tela e restaure com um único comando ou atalho."
                    font.pixelSize: 12
                    color: mutedTextColor
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 10
                    Button {
                        text: "Salvar Workspace Atual"
                        highlighted: true
                        Material.accent: themeAccent
                        onClicked: {
                            win.triggerAction("workspaces-save");
                            statusMessage.text = "Snapshot do workspace salvo com sucesso!";
                            statusTimer.restart();
                        }
                    }
                    Button {
                        text: "Restaurar Preset"
                        onClicked: {
                            win.triggerAction("workspaces-restore");
                            statusMessage.text = "Restaurando janelas do workspace...";
                            statusTimer.restart();
                        }
                    }
                }
            }
        }

        Text {
            text: "Utilitários do Ecossistema Integrados"
            font.pixelSize: 14
            font.bold: true
            color: themeForeground
            Layout.topMargin: 4
        }

        // Grid of PowerToys Tools
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            GridLayout {
                width: parent.width
                columns: 2
                columnSpacing: 14
                rowSpacing: 14

                // Color Picker
                ToolCard {
                    iconText: "🎯"
                    toolTitle: "Color Picker"
                    toolDesc: "Conta-gotas de tela com zoom e cópia instantânea (HEX/RGB)."
                    buttonLabel: "Capturar Cor"
                    themeForeground: win.themeForeground
                    raisedColor: win.raisedColor
                    cardBorderColor: win.cardBorderColor
                    mutedTextColor: win.mutedTextColor
                    accentColor: win.themeAccent
                    onTriggered: {
                        win.triggerAction("picker");
                        statusMessage.text = "Acionando seletor de cores...";
                        statusTimer.restart();
                    }
                }

                // Text Extractor
                ToolCard {
                    iconText: "✂️"
                    toolTitle: "Text Extractor (OCR)"
                    toolDesc: "Recorta uma área da tela e extrai o texto para o clipboard."
                    buttonLabel: "Extrair Texto"
                    themeForeground: win.themeForeground
                    raisedColor: win.raisedColor
                    cardBorderColor: win.cardBorderColor
                    mutedTextColor: win.mutedTextColor
                    accentColor: win.themeAccent
                    onTriggered: {
                        win.triggerAction("ocr");
                        statusMessage.text = "Selecione a área para OCR...";
                        statusTimer.restart();
                    }
                }

                // Omacut
                ToolCard {
                    iconText: "🎬"
                    toolTitle: "Omacut"
                    toolDesc: "Cortador e trimmer de vídeo ultra-rápido com FFmpeg."
                    buttonLabel: "Abrir Omacut"
                    themeForeground: win.themeForeground
                    raisedColor: win.raisedColor
                    cardBorderColor: win.cardBorderColor
                    mutedTextColor: win.mutedTextColor
                    accentColor: win.themeAccent
                    onTriggered: {
                        win.triggerAction("cut");
                        statusMessage.text = "Abrindo Omacut...";
                        statusTimer.restart();
                    }
                }

                // Omawrite
                ToolCard {
                    iconText: "✍️"
                    toolTitle: "Omawrite"
                    toolDesc: "Editor Markdown minimalista sem distrações para escrita."
                    buttonLabel: "Abrir Omawrite"
                    themeForeground: win.themeForeground
                    raisedColor: win.raisedColor
                    cardBorderColor: win.cardBorderColor
                    mutedTextColor: win.mutedTextColor
                    accentColor: win.themeAccent
                    onTriggered: {
                        win.triggerAction("write");
                        statusMessage.text = "Abrindo Omawrite...";
                        statusTimer.restart();
                    }
                }

                // Omasnap
                ToolCard {
                    iconText: "📸"
                    toolTitle: "Omasnap"
                    toolDesc: "Screenshot nativo Wayland com editor de anotações e setas."
                    buttonLabel: "Abrir Omasnap"
                    themeForeground: win.themeForeground
                    raisedColor: win.raisedColor
                    cardBorderColor: win.cardBorderColor
                    mutedTextColor: win.mutedTextColor
                    accentColor: win.themeAccent
                    onTriggered: {
                        win.triggerAction("snap");
                        statusMessage.text = "Abrindo Omasnap...";
                        statusTimer.restart();
                    }
                }

                // Omacalc
                ToolCard {
                    iconText: "🧮"
                    toolTitle: "Omacalc"
                    toolDesc: "Calculadora simples e elegante integrada ao tema."
                    buttonLabel: "Abrir Omacalc"
                    themeForeground: win.themeForeground
                    raisedColor: win.raisedColor
                    cardBorderColor: win.cardBorderColor
                    mutedTextColor: win.mutedTextColor
                    accentColor: win.themeAccent
                    onTriggered: {
                        win.triggerAction("calc");
                        statusMessage.text = "Abrindo Omacalc...";
                        statusTimer.restart();
                    }
                }

                // Awake
                ToolCard {
                    iconText: "☕"
                    toolTitle: "Awake"
                    toolDesc: "Inibe temporariamente o bloqueio e suspensão da tela."
                    buttonLabel: "Alternar Awake"
                    themeForeground: win.themeForeground
                    raisedColor: win.raisedColor
                    cardBorderColor: win.cardBorderColor
                    mutedTextColor: win.mutedTextColor
                    accentColor: win.themeAccent
                    onTriggered: {
                        win.triggerAction("awake");
                        statusMessage.text = "Inibição de suspensão alternada!";
                        statusTimer.restart();
                    }
                }

                // Flea
                ToolCard {
                    iconText: "📁"
                    toolTitle: "Flea"
                    toolDesc: "Gerenciador de arquivos rápido e orientado a teclado."
                    buttonLabel: "Abrir Flea"
                    themeForeground: win.themeForeground
                    raisedColor: win.raisedColor
                    cardBorderColor: win.cardBorderColor
                    mutedTextColor: win.mutedTextColor
                    accentColor: win.themeAccent
                    onTriggered: {
                        win.triggerAction("flea");
                        statusMessage.text = "Abrindo Flea...";
                        statusTimer.restart();
                    }
                }
            }
        }

        // Status bar
        RowLayout {
            Layout.fillWidth: true
            Text {
                id: statusMessage
                text: "Pressione Ctrl+Q ou Esc para fechar"
                font.pixelSize: 12
                color: mutedTextColor
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "Omarchy Quattro"
                font.pixelSize: 11
                color: mutedTextColor
            }
        }
    }

    Timer {
        id: statusTimer
        interval: 3000
        onTriggered: statusMessage.text = "Pressione Ctrl+Q ou Esc para fechar"
    }

    component ToolCard: Rectangle {
        property string iconText: "📦"
        property string toolTitle: ""
        property string toolDesc: ""
        property string buttonLabel: "Executar"
        property color themeForeground: "#ffffff"
        property color raisedColor: "#202020"
        property color cardBorderColor: "#333333"
        property color mutedTextColor: "#888888"
        property color accentColor: "#5dffb0"
        signal triggered()

        Layout.fillWidth: true
        height: 130
        radius: 12
        color: raisedColor
        border.color: cardBorderColor
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            RowLayout {
                spacing: 8
                Text {
                    text: iconText
                    font.pixelSize: 16
                }
                Text {
                    text: toolTitle
                    font.pixelSize: 14
                    font.bold: true
                    color: themeForeground
                    Layout.fillWidth: true
                }
            }

            Text {
                text: toolDesc
                font.pixelSize: 11
                color: mutedTextColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Button {
                text: buttonLabel
                Layout.alignment: Qt.AlignRight
                Material.accent: accentColor
                onClicked: triggered()
            }
        }
    }
}
