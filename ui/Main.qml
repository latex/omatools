import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: win
    width: 940
    height: 640
    minimumWidth: 800
    minimumHeight: 540
    visible: true
    title: "OmaTools — PowerToys for Omarchy"

    // Theme properties passed by omatools launcher or fallback
    property string themeBackground: "#2d353b"
    property string themeForeground: "#d3c6aa"
    property string themeAccent: "#7fbbb3"
    property string themeSelection: "#3d484d"
    property string themeMuted: "#859289"
    property bool darkMode: true
    property string apiPort: ""

    property int currentTab: 0

    function triggerAction(actionName, feedbackMsg) {
        if (feedbackMsg) {
            notify(feedbackMsg);
        }
        if (!apiPort) return;
        let xhr = new XMLHttpRequest();
        xhr.open("POST", "http://127.0.0.1:" + apiPort + "/action/" + actionName);
        xhr.send();
    }

    function notify(msg) {
        statusMessage.text = msg;
        statusIndicator.color = themeAccent;
        statusTimer.restart();
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

    readonly property color colBg: Qt.color(themeBackground)
    readonly property color colFg: Qt.color(themeForeground)
    readonly property color colAccent: Qt.color(themeAccent)
    readonly property color colSidebarBg: mixColors(colBg, colFg, 0.03)
    readonly property color colCardBg: mixColors(colBg, colFg, 0.06)
    readonly property color colCardHover: mixColors(colBg, colFg, 0.10)
    readonly property color colCardBorder: mixColors(colBg, colFg, 0.12)
    readonly property color colSubtleBorder: mixColors(colBg, colFg, 0.08)
    readonly property color colMutedText: Qt.color(themeMuted)
    readonly property color colAccentSubtle: Qt.rgba(colAccent.r, colAccent.g, colAccent.b, 0.12)
    readonly property color colAccentBorder: Qt.rgba(colAccent.r, colAccent.g, colAccent.b, 0.35)

    Material.theme: darkMode ? Material.Dark : Material.Light
    Material.accent: themeAccent
    color: colBg

    // Global keyboard shortcuts (tui-ux-design guidelines)
    Shortcut { sequence: "Ctrl+Q"; onActivated: Qt.quit() }
    Shortcut { sequence: "Escape"; onActivated: Qt.quit() }
    Shortcut { sequence: "1"; onActivated: currentTab = 0 }
    Shortcut { sequence: "2"; onActivated: currentTab = 1 }
    Shortcut { sequence: "3"; onActivated: currentTab = 2 }
    Shortcut { sequence: "4"; onActivated: currentTab = 3 }
    Shortcut { sequence: "5"; onActivated: currentTab = 4 }
    Shortcut { sequence: "6"; onActivated: currentTab = 5 }
    Shortcut { sequence: "Up"; onActivated: if (currentTab > 0) currentTab-- }
    Shortcut { sequence: "Down"; onActivated: if (currentTab < 5) currentTab++ }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // =====================================================================
        // SIDEBAR (MASTER PANEL)
        // =====================================================================
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 240
            Layout.minimumWidth: 220
            color: colSidebarBg

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: colCardBorder
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 16

                // Brand Header
                RowLayout {
                    spacing: 12
                    Layout.fillWidth: true

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 10
                        color: colAccentSubtle
                        border.color: colAccentBorder
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "◈"
                            font.pixelSize: 18
                            font.bold: true
                            color: colAccent
                        }
                    }

                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "OMATOOLS"
                            font.pixelSize: 15
                            font.bold: true
                            font.letterSpacing: 1.2
                            color: colFg
                        }
                        Text {
                            text: "PowerToys for Omarchy"
                            font.pixelSize: 11
                            color: colMutedText
                        }
                    }
                }

                // Section Label
                Text {
                    text: "MÓDULOS"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.5
                    color: colMutedText
                    Layout.topMargin: 8
                    Layout.leftMargin: 4
                }

                // Navigation Items
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    NavItem {
                        index: 0
                        symbol: "◈"
                        label: "Workspaces"
                        sublabel: "Sessões & Snapshots"
                        shortcutKey: "1"
                    }
                    NavItem {
                        index: 1
                        symbol: "⊞"
                        label: "FancyZones"
                        sublabel: "Grids & Encaixe"
                        shortcutKey: "2"
                    }
                    NavItem {
                        index: 2
                        symbol: "✦"
                        label: "Utilitários"
                        sublabel: "Picker, OCR, Awake"
                        shortcutKey: "3"
                    }
                    NavItem {
                        index: 3
                        symbol: "◆"
                        label: "Apps Omacom"
                        sublabel: "Suíte do Sistema"
                        shortcutKey: "4"
                    }
                    NavItem {
                        index: 4
                        symbol: "⌨"
                        label: "Guia de Atalhos"
                        sublabel: "Matriz PowerToys"
                        shortcutKey: "5"
                    }
                    NavItem {
                        index: 5
                        symbol: "λ"
                        label: "Agentes IA"
                        sublabel: "Modelos & Agentes"
                        shortcutKey: "6"
                    }
                }

                Item { Layout.fillHeight: true }

                // Sidebar Footer Status
                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    radius: 8
                    color: colCardBg
                    border.color: colSubtleBorder
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: apiPort ? colAccent : colMutedText
                        }

                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: apiPort ? "IPC Ativo (Porta " + apiPort + ")" : "IPC Standalone"
                                font.pixelSize: 11
                                font.bold: true
                                color: colFg
                            }
                            Text {
                                text: "Hyprland Compositor"
                                font.pixelSize: 10
                                color: colMutedText
                            }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // DETAIL PANEL (CONTENT AREA)
        // =====================================================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Header Bar
            Rectangle {
                Layout.fillWidth: true
                height: 56
                color: colBg

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: colCardBorder
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: currentTab === 0 ? "Workspaces — Gerenciador de Sessão Multi-Janela" :
                                  currentTab === 1 ? "FancyZones — Posicionamento Magnético e Divisão de Tela" :
                                  currentTab === 2 ? "Utilitários Core — Ferramentas de Produtividade" :
                                  currentTab === 3 ? "Ecossistema Omacom — Aplicações Integradas" :
                                  currentTab === 4 ? "Guia de Atalhos — Mapeamento PowerToys ➔ Omarchy" :
                                                     "Agentes IA & LLM — Engenharia & Automações Locais"
                            font.pixelSize: 15
                            font.bold: true
                            color: colFg
                        }
                        Text {
                            text: currentTab === 0 ? "Hyprland IPC • Captura e restauração de arranjos com zero latência" :
                                  currentTab === 1 ? "Encaixe em zonas pré-definidas, centralização e fixação Always on Top" :
                                  currentTab === 2 ? "Ações rápidas no compositor: seletor de cores, extração OCR e controle idle" :
                                  currentTab === 3 ? "Aplicações nativas ultra-leves desenhadas para o desktop Omarchy" :
                                  currentTab === 4 ? "Equivalência oficial entre atalhos do Windows PowerToys e comandos Linux" :
                                                     "Atalhos para agentes especializados e transformações inteligentes com IA local"
                            font.pixelSize: 11
                            color: colMutedText
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "✕ Fechar"
                        flat: true
                        font.pixelSize: 12
                        onClicked: Qt.quit()
                    }
                }
            }

            // Scrollable Content View
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Item {
                    width: parent.width
                    implicitHeight: contentStack.implicitHeight + 48

                    ColumnLayout {
                        id: contentStack
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 24
                        spacing: 20

                        // -----------------------------------------------------
                        // TAB 0: WORKSPACES
                        // -----------------------------------------------------
                        ColumnLayout {
                            visible: currentTab === 0
                            Layout.fillWidth: true
                            spacing: 16

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 14

                                // Card Snapshot
                                ActionCard {
                                    Layout.fillWidth: true
                                    symbol: "◈"
                                    title: "Capturar Workspace Atual"
                                    badge: "Snapshot j/clients"
                                    description: "Varre todas as janelas do workspace ativo no Hyprland, registrando posições exatas, dimensões e classes de execução."
                                    primaryButtonText: "Salvar Snapshot"
                                    primaryHighlighted: true
                                    onPrimaryClicked: {
                                        win.triggerAction("workspaces-save", "Snapshot do workspace capturado com sucesso!");
                                    }
                                }

                                // Card Restore
                                ActionCard {
                                    Layout.fillWidth: true
                                    symbol: "↺"
                                    title: "Restaurar Preset Padrão"
                                    badge: "dispatch exec"
                                    description: "Restaura o arranjo de aplicativos salvo anteriormente, recriando as instâncias nos respectivos workspaces."
                                    primaryButtonText: "Restaurar Preset"
                                    primaryHighlighted: false
                                    onPrimaryClicked: {
                                        win.triggerAction("workspaces-restore", "Iniciando restauração das janelas do workspace...");
                                    }
                                }
                            }

                            // Info & Quick CLI box
                            Rectangle {
                                Layout.fillWidth: true
                                radius: 10
                                color: colCardBg
                                border.color: colCardBorder
                                border.width: 1
                                implicitHeight: infoCol.implicitHeight + 24

                                ColumnLayout {
                                    id: infoCol
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 8

                                    Text {
                                        text: "COMANDOS DE LINHA DE COMANDO EQUIVALENTES"
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.letterSpacing: 1.0
                                        color: colAccent
                                    }

                                    Text {
                                        text: "• Capturar workspace atual:   omatools workspaces capture -w 1 -n meu-preset\n• Restaurar preset nomeado:   omatools workspaces restore meu-preset\n• Listar todos os presets:    omatools workspaces list"
                                        font.pixelSize: 12
                                        font.family: "monospace"
                                        color: colFg
                                    }
                                }
                            }
                        }

                        // -----------------------------------------------------
                        // TAB 1: FANCYZONES & WINDOW MANAGEMENT
                        // -----------------------------------------------------
                        ColumnLayout {
                            visible: currentTab === 1
                            Layout.fillWidth: true
                            spacing: 16

                            Text {
                                text: "ZONAS RÁPIDAS DE ENCAIXE (FANCYZONES)"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 1.0
                                color: colAccent
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 14
                                rowSpacing: 14

                                ZoneTile {
                                    Layout.fillWidth: true
                                    symbol: "◀"
                                    name: "Metade Esquerda"
                                    detail: "Divide a tela na vertical e ancora a janela na porção esquerda."
                                    shortcutHint: "Win + Left"
                                    onTriggered: win.triggerAction("zones-left", "Janela encaixada na metade esquerda");
                                }

                                ZoneTile {
                                    Layout.fillWidth: true
                                    symbol: "▶"
                                    name: "Metade Direita"
                                    detail: "Divide a tela na vertical e ancora a janela na porção direita."
                                    shortcutHint: "Win + Right"
                                    onTriggered: win.triggerAction("zones-right", "Janela encaixada na metade direita");
                                }

                                ZoneTile {
                                    Layout.fillWidth: true
                                    symbol: "▣"
                                    name: "Centro Prioritário"
                                    detail: "Centraliza a janela ativa com proporções de foco prioritário."
                                    shortcutHint: "Win + Up"
                                    onTriggered: win.triggerAction("zones-center", "Janela centralizada com foco prioritário");
                                }

                                ZoneTile {
                                    Layout.fillWidth: true
                                    symbol: "⊞"
                                    name: "Grid Quadrante"
                                    detail: "Posiciona no grid 2x2 para ambientes multi-tarefa densos."
                                    shortcutHint: "Win + Shift + `"
                                    onTriggered: win.triggerAction("zones-grid", "Janela posicionada no Grid");
                                }
                            }

                            Text {
                                text: "AÇÕES ESPECIAIS DE JANELA"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 1.0
                                color: colAccent
                                Layout.topMargin: 8
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 14

                                ActionCard {
                                    Layout.fillWidth: true
                                    symbol: "📌"
                                    title: "Always on Top"
                                    badge: "Win + Ctrl + T"
                                    description: "Alterna o estado flutuante e fixa a janela no topo sobre todas as outras."
                                    primaryButtonText: "Alternar Fixação"
                                    primaryHighlighted: true
                                    onPrimaryClicked: win.triggerAction("pin", "Always on Top alternado na janela ativa");
                                }

                                ActionCard {
                                    Layout.fillWidth: true
                                    symbol: "📄"
                                    title: "Colar como Texto Puro"
                                    badge: "Win + Ctrl + Alt + V"
                                    description: "Sanitiza o conteúdo da área de transferência removendo HTML e formatação rica."
                                    primaryButtonText: "Colar Texto Puro"
                                    primaryHighlighted: false
                                    onPrimaryClicked: win.triggerAction("paste-plain", "Texto puro colado da área de transferência");
                                }
                            }
                        }

                        // -----------------------------------------------------
                        // TAB 2: UTILITIES (PICKER, OCR, AWAKE, LOCKSMITH)
                        // -----------------------------------------------------
                        ColumnLayout {
                            visible: currentTab === 2
                            Layout.fillWidth: true
                            spacing: 16

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 14
                                rowSpacing: 14

                                UtilCard {
                                    Layout.fillWidth: true
                                    symbol: "✦"
                                    title: "Color Picker"
                                    subtitle: "Win + Shift + C"
                                    desc: "Conta-gotas de tela com lente de aumento sob o cursor e cópia em HEX/RGB."
                                    btnText: "Capturar Cor"
                                    onAction: win.triggerAction("picker", "Seletor de cor ativado. Clique no pixel desejado.");
                                }

                                UtilCard {
                                    Layout.fillWidth: true
                                    symbol: "✂"
                                    title: "Text Extractor (OCR)"
                                    subtitle: "Win + Shift + T"
                                    desc: "Recorte retangular na tela com reconhecimento ótico de caracteres instantâneo."
                                    btnText: "Extrair Texto"
                                    onAction: win.triggerAction("ocr", "Selecione a área da tela para extração OCR.");
                                }

                                UtilCard {
                                    Layout.fillWidth: true
                                    symbol: "⚡"
                                    title: "Awake"
                                    subtitle: "Inibidor de Suspensão"
                                    desc: "Inibe temporariamente o bloqueio de tela, descanso e idle timeout no Hyprland."
                                    btnText: "Alternar Awake"
                                    onAction: win.triggerAction("awake", "Estado de inibição de suspensão alternado!");
                                }

                                UtilCard {
                                    Layout.fillWidth: true
                                    symbol: "⚲"
                                    title: "File Locksmith"
                                    subtitle: "Inspeção de Processos"
                                    desc: "Descobre quais processos ou serviços do Linux estão bloqueando o arquivo."
                                    btnText: "Info de Uso"
                                    onAction: win.notify("Use: omatools locksmith <caminho_do_arquivo> no terminal.");
                                }
                            }
                        }

                        // -----------------------------------------------------
                        // TAB 3: OMACOM APPS
                        // -----------------------------------------------------
                        ColumnLayout {
                            visible: currentTab === 3
                            Layout.fillWidth: true
                            spacing: 16

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 14
                                rowSpacing: 14

                                UtilCard {
                                    Layout.fillWidth: true
                                    symbol: "◆"
                                    title: "Omasnap"
                                    subtitle: "Screenshot & Anotações"
                                    desc: "Captura de tela nativa Wayland com editor vetorial de anotações e setas."
                                    btnText: "Abrir Omasnap"
                                    onAction: win.triggerAction("snap", "Abrindo Omasnap...");
                                }

                                UtilCard {
                                    Layout.fillWidth: true
                                    symbol: "◆"
                                    title: "Omacut"
                                    subtitle: "Cortador de Vídeo"
                                    desc: "Trimmer de vídeo ultra-rápido com processamento sem perda via FFmpeg."
                                    btnText: "Abrir Omacut"
                                    onAction: win.triggerAction("cut", "Abrindo Omacut...");
                                }

                                UtilCard {
                                    Layout.fillWidth: true
                                    symbol: "◆"
                                    title: "Omawrite"
                                    subtitle: "Editor Markdown"
                                    desc: "Editor de notas e textos sem distrações, integrado ao tema Omarchy."
                                    btnText: "Abrir Omawrite"
                                    onAction: win.triggerAction("write", "Abrindo Omawrite...");
                                }

                                UtilCard {
                                    Layout.fillWidth: true
                                    symbol: "◆"
                                    title: "Omacalc"
                                    subtitle: "Calculadora Minimalista"
                                    desc: "Calculadora de alta precisão e ergonomia visual integrada ao ecossistema."
                                    btnText: "Abrir Omacalc"
                                    onAction: win.triggerAction("calc", "Abrindo Omacalc...");
                                }

                                UtilCard {
                                    Layout.fillWidth: true
                                    symbol: "◆"
                                    title: "Flea"
                                    subtitle: "Gerenciador de Arquivos"
                                    desc: "Navegação rápida em diretórios, orientada totalmente a teclado."
                                    btnText: "Abrir Flea"
                                    onAction: win.triggerAction("flea", "Abrindo Flea...");
                                }
                            }
                        }

                        // -----------------------------------------------------
                        // TAB 4: SHORTCUT GUIDE
                        // -----------------------------------------------------
                        ColumnLayout {
                            visible: currentTab === 4
                            Layout.fillWidth: true
                            spacing: 14

                            Rectangle {
                                Layout.fillWidth: true
                                radius: 10
                                color: colCardBg
                                border.color: colCardBorder
                                border.width: 1
                                implicitHeight: guideCol.implicitHeight + 28

                                ColumnLayout {
                                    id: guideCol
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 10

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: "FERRAMENTA"
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: colMutedText
                                            Layout.preferredWidth: 160
                                        }
                                        Text {
                                            text: "ATALHO WINDOWS"
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: colMutedText
                                            Layout.preferredWidth: 180
                                        }
                                        Text {
                                            text: "EQUIVALENTE OMATOOLS (LINUX)"
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: colMutedText
                                            Layout.fillWidth: true
                                        }
                                    }

                                    Rectangle { Layout.fillWidth: true; height: 1; color: colSubtleBorder }

                                    GuideRow { tool: "PowerToys Run"; winKey: "Alt + Space"; omaCmd: "omatools gui" }
                                    GuideRow { tool: "FancyZones (Esq)"; winKey: "Win + Left"; omaCmd: "omatools zones left" }
                                    GuideRow { tool: "FancyZones (Dir)"; winKey: "Win + Right"; omaCmd: "omatools zones right" }
                                    GuideRow { tool: "FancyZones (Centro)"; winKey: "Win + Up"; omaCmd: "omatools zones center" }
                                    GuideRow { tool: "FancyZones (Grid)"; winKey: "Win + Shift + `"; omaCmd: "omatools zones snap -l grid2x2" }
                                    GuideRow { tool: "Always on Top"; winKey: "Win + Ctrl + T"; omaCmd: "omatools pin" }
                                    GuideRow { tool: "Color Picker"; winKey: "Win + Shift + C"; omaCmd: "omatools picker" }
                                    GuideRow { tool: "Text Extractor"; winKey: "Win + Shift + T"; omaCmd: "omatools ocr" }
                                    GuideRow { tool: "Workspaces"; winKey: "Win + Ctrl + `"; omaCmd: "omatools workspaces restore" }
                                    GuideRow { tool: "Paste Plain Text"; winKey: "Win + Ctrl + Alt + V"; omaCmd: "omatools paste-plain" }
                                    GuideRow { tool: "Screen Ruler"; winKey: "Win + Shift + M"; omaCmd: "omatools snap" }
                                    GuideRow { tool: "Awake"; winKey: "Bandeja / Menu"; omaCmd: "omatools awake" }
                                }
                            }
                        }

                        // -----------------------------------------------------
                        // TAB 5: AGENTES IA & LLM
                        // -----------------------------------------------------
                        ColumnLayout {
                            visible: currentTab === 5
                            Layout.fillWidth: true
                            spacing: 18

                            // Section: AI Paste & Clipboard Transformations
                            Rectangle {
                                Layout.fillWidth: true
                                radius: 10
                                color: colCardBg
                                border.color: colCardBorder
                                border.width: 1
                                implicitHeight: aiPasteCol.implicitHeight + 28

                                ColumnLayout {
                                    id: aiPasteCol
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: "λ Transformação de Clipboard com IA Local (Advanced AI Paste)"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: colFg
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: "Ollama / llama-server"
                                            font.pixelSize: 10
                                            color: colAccent
                                        }
                                    }

                                    Text {
                                        text: "Transforme instantaneamente o conteúdo copiado na área de transferência com modelos locais de alta performance."
                                        font.pixelSize: 11
                                        color: colMutedText
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }

                                    RowLayout {
                                        spacing: 8
                                        Button {
                                            text: "✦ Resumir Clipboard"
                                            highlighted: true
                                            Material.accent: themeAccent
                                            onClicked: win.triggerAction("ia-transform-summary", "Resumindo texto da clipboard com IA local...")
                                        }
                                        Button {
                                            text: "✦ Traduzir p/ Inglês"
                                            onClicked: win.triggerAction("ia-transform-translate", "Traduzindo texto da clipboard para inglês...")
                                        }
                                        Button {
                                            text: "✦ Explicar Código"
                                            onClicked: win.triggerAction("ia-transform-explain", "Gerando explicação técnica do código copiado...")
                                        }
                                        Button {
                                            text: "✦ Gerar Teste Rust"
                                            onClicked: win.triggerAction("ia-transform-test", "Gerando suíte de testes unitários para o código...")
                                        }
                                    }
                                }
                            }

                            Text {
                                text: "AGENTES ESPECIALISTAS INTEGRADOS"
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1.5
                                color: colMutedText
                            }

                            // Grid of Agents
                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 14
                                rowSpacing: 14

                                AgentCard {
                                    agentId: "eng-ia"
                                    symbol: "◈"
                                    name: "Engenheiro de IA & Kaizen"
                                    role: "MCP, RAG, Memória & Otimização de Modelos"
                                    model: "qwen3.6:27b"
                                    shortcutText: "Alt + 1"
                                    onSpawnClicked: win.triggerAction("ia-spawn-eng-ia", "Abrindo terminal com agente eng-ia...")
                                }

                                AgentCard {
                                    agentId: "rust-app"
                                    symbol: "⚙"
                                    name: "Engenheiro Rust 2024"
                                    role: "Sistemas de Baixo Nível, IPC & Concorrência"
                                    model: "qwen3.6:27b"
                                    shortcutText: "Alt + 2"
                                    onSpawnClicked: win.triggerAction("ia-spawn-rust-app", "Abrindo terminal com agente rust-app...")
                                }

                                AgentCard {
                                    agentId: "qa-app"
                                    symbol: "✓"
                                    name: "Auditor de QA 10/10"
                                    role: "Pirâmide de Testes, Regressão & Validação"
                                    model: "gemma4:latest"
                                    shortcutText: "Alt + 3"
                                    onSpawnClicked: win.triggerAction("ia-spawn-qa-app", "Abrindo terminal com agente qa-app...")
                                }

                                AgentCard {
                                    agentId: "devops-app"
                                    symbol: "⎘"
                                    name: "DevOps & Automações"
                                    role: "Pipelines CI/CD, Docker, Builds & Deploy"
                                    model: "qwen3:8b"
                                    shortcutText: "Alt + 4"
                                    onSpawnClicked: win.triggerAction("ia-spawn-devops-app", "Abrindo terminal com agente devops-app...")
                                }

                                AgentCard {
                                    agentId: "dba-app"
                                    symbol: "⛁"
                                    name: "DBA PostgreSQL & pgvector"
                                    role: "Modelagem Relacional, Índices & Tuning"
                                    model: "qwen3.6:27b"
                                    shortcutText: "Alt + 5"
                                    onSpawnClicked: win.triggerAction("ia-spawn-dba-app", "Abrindo terminal com agente dba-app...")
                                }

                                AgentCard {
                                    agentId: "iam-app"
                                    symbol: "🔒"
                                    name: "IAM, Segredos & Segurança"
                                    role: "Zero Plaintext Secrets & Cofre Pass GPG"
                                    model: "qwen3:8b"
                                    shortcutText: "Alt + 6"
                                    onSpawnClicked: win.triggerAction("ia-spawn-iam-app", "Abrindo terminal com agente iam-app...")
                                }

                                AgentCard {
                                    agentId: "ui-app"
                                    symbol: "🎨"
                                    name: "UI/UX & Frontend Designer"
                                    role: "TUI Ratatui, QtQuick/QML & Acessibilidade"
                                    model: "gemma4:latest"
                                    shortcutText: "Alt + 7"
                                    onSpawnClicked: win.triggerAction("ia-spawn-ui-app", "Abrindo terminal com agente ui-app...")
                                }

                                AgentCard {
                                    agentId: "hermes"
                                    symbol: "⚡"
                                    name: "Hermes Agent"
                                    role: "Sessão Interativa Direta Hermes"
                                    model: "default local"
                                    shortcutText: "CLI"
                                    onSpawnClicked: win.triggerAction("ia-spawn-hermes", "Abrindo terminal com Hermes Agent...")
                                }
                            }
                        }
                    }
                }
            }

            // =================================================================
            // BOTTOM STATUS BAR
            // =================================================================
            Rectangle {
                Layout.fillWidth: true
                height: 38
                color: colSidebarBg

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: colCardBorder
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20

                    Rectangle {
                        id: statusIndicator
                        width: 7
                        height: 7
                        radius: 3.5
                        color: colAccent
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    Text {
                        id: statusMessage
                        text: "Pronto • Selecione uma ferramenta ou navegue com [1-6]"
                        font.pixelSize: 11
                        color: colMutedText
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 12

                        Text {
                            text: "[ 1-6 ] Seções"
                            font.pixelSize: 10
                            font.family: "monospace"
                            color: colMutedText
                        }
                        Text {
                            text: "[ ↑↓ ] Navegar"
                            font.pixelSize: 10
                            font.family: "monospace"
                            color: colMutedText
                        }
                        Text {
                            text: "[ Esc ] Sair"
                            font.pixelSize: 10
                            font.family: "monospace"
                            color: colMutedText
                        }
                        Text {
                            text: "• Omarchy Quattro"
                            font.pixelSize: 10
                            color: colMutedText
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: statusTimer
        interval: 4000
        onTriggered: {
            statusMessage.text = "Pronto • Selecione uma ferramenta ou navegue com [1-5]";
            statusIndicator.color = colAccent;
        }
    }

    // =========================================================================
    // REUSABLE SUBCOMPONENTS
    // =========================================================================

    component NavItem: Rectangle {
        property int index: 0
        property string symbol: "◈"
        property string label: ""
        property string sublabel: ""
        property string shortcutKey: "1"

        readonly property bool isActive: win.currentTab === index

        Layout.fillWidth: true
        height: 48
        radius: 8
        color: isActive ? colCardHover : (mouseNav.containsMouse ? colCardBg : "transparent")
        border.color: isActive ? colAccentBorder : "transparent"
        border.width: 1

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 6
            width: 3
            radius: 1.5
            color: colAccent
            visible: isActive
        }

        MouseArea {
            id: mouseNav
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: win.currentTab = index
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 12
            spacing: 10

            Text {
                text: symbol
                font.pixelSize: 14
                color: isActive ? colAccent : colMutedText
            }

            ColumnLayout {
                spacing: 1
                Layout.fillWidth: true
                Text {
                    text: label
                    font.pixelSize: 13
                    font.bold: isActive
                    color: isActive ? colFg : colMutedText
                }
                Text {
                    text: sublabel
                    font.pixelSize: 10
                    color: colMutedText
                }
            }

            Rectangle {
                width: 18
                height: 18
                radius: 4
                color: isActive ? colAccentSubtle : "transparent"
                border.color: isActive ? colAccentBorder : colSubtleBorder
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: shortcutKey
                    font.pixelSize: 10
                    font.family: "monospace"
                    font.bold: true
                    color: isActive ? colAccent : colMutedText
                }
            }
        }
    }

    component ActionCard: Rectangle {
        property string symbol: "◈"
        property string title: ""
        property string badge: ""
        property string description: ""
        property string primaryButtonText: "Executar"
        property bool primaryHighlighted: true
        signal primaryClicked()

        radius: 10
        color: colCardBg
        border.color: colCardBorder
        border.width: 1
        implicitHeight: cardCol.implicitHeight + 28

        ColumnLayout {
            id: cardCol
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: symbol
                    font.pixelSize: 14
                    color: colAccent
                }

                Text {
                    text: title
                    font.pixelSize: 14
                    font.bold: true
                    color: colFg
                    Layout.fillWidth: true
                }

                Rectangle {
                    radius: 4
                    color: colAccentSubtle
                    border.color: colAccentBorder
                    border.width: 1
                    implicitWidth: badgeText.implicitWidth + 8
                    implicitHeight: 20

                    Text {
                        id: badgeText
                        anchors.centerIn: parent
                        text: badge
                        font.pixelSize: 10
                        font.bold: true
                        color: colAccent
                    }
                }
            }

            Text {
                text: description
                font.pixelSize: 11
                color: colMutedText
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Button {
                text: primaryButtonText
                highlighted: primaryHighlighted
                Material.accent: themeAccent
                font.pixelSize: 12
                Layout.alignment: Qt.AlignRight
                onClicked: primaryClicked()
            }
        }
    }

    component ZoneTile: Rectangle {
        property string symbol: "◀"
        property string name: ""
        property string detail: ""
        property string shortcutHint: ""
        signal triggered()

        radius: 10
        color: tileMouse.containsMouse ? colCardHover : colCardBg
        border.color: tileMouse.containsMouse ? colAccentBorder : colCardBorder
        border.width: 1
        implicitHeight: tileCol.implicitHeight + 24

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: triggered()
        }

        ColumnLayout {
            id: tileCol
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 26
                    height: 26
                    radius: 6
                    color: colAccentSubtle
                    border.color: colAccentBorder
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: symbol
                        font.pixelSize: 13
                        color: colAccent
                    }
                }

                Text {
                    text: name
                    font.pixelSize: 13
                    font.bold: true
                    color: colFg
                    Layout.fillWidth: true
                }

                Text {
                    text: shortcutHint
                    font.pixelSize: 10
                    font.family: "monospace"
                    color: colMutedText
                }
            }

            Text {
                text: detail
                font.pixelSize: 11
                color: colMutedText
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }

    component UtilCard: Rectangle {
        property string symbol: "✦"
        property string title: ""
        property string subtitle: ""
        property string desc: ""
        property string btnText: "Executar"
        signal action()

        radius: 10
        color: colCardBg
        border.color: colCardBorder
        border.width: 1
        implicitHeight: utilCol.implicitHeight + 28

        ColumnLayout {
            id: utilCol
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: symbol
                    font.pixelSize: 14
                    color: colAccent
                }

                Text {
                    text: title
                    font.pixelSize: 14
                    font.bold: true
                    color: colFg
                    Layout.fillWidth: true
                }

                Text {
                    text: subtitle
                    font.pixelSize: 10
                    font.family: "monospace"
                    color: colMutedText
                }
            }

            Text {
                text: desc
                font.pixelSize: 11
                color: colMutedText
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Button {
                text: btnText
                font.pixelSize: 12
                Material.accent: themeAccent
                Layout.alignment: Qt.AlignRight
                onClicked: action()
            }
        }
    }

    component GuideRow: RowLayout {
        property string tool: ""
        property string winKey: ""
        property string omaCmd: ""

        Layout.fillWidth: true
        spacing: 8

        Text {
            text: tool
            font.pixelSize: 12
            font.bold: true
            color: colFg
            Layout.preferredWidth: 160
        }

        Rectangle {
            Layout.preferredWidth: 180
            height: 22
            radius: 4
            color: colSidebarBg
            border.color: colSubtleBorder
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: winKey
                font.pixelSize: 10
                font.family: "monospace"
                color: colAccent
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 22
            radius: 4
            color: colSidebarBg
            border.color: colSubtleBorder
            border.width: 1

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: omaCmd
                font.pixelSize: 11
                font.family: "monospace"
                color: colFg
            }
        }
    }

    component AgentCard: Rectangle {
        property string agentId: ""
        property string symbol: "◈"
        property string name: ""
        property string role: ""
        property string model: "default"
        property string shortcutText: ""
        signal spawnClicked()

        radius: 10
        color: colCardBg
        border.color: colCardBorder
        border.width: 1
        implicitHeight: agentCol.implicitHeight + 28

        ColumnLayout {
            id: agentCol
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: symbol
                    font.pixelSize: 14
                    color: colAccent
                }

                Text {
                    text: name
                    font.pixelSize: 13
                    font.bold: true
                    color: colFg
                    Layout.fillWidth: true
                }

                Rectangle {
                    radius: 4
                    color: colAccentSubtle
                    border.color: colAccentBorder
                    border.width: 1
                    implicitWidth: scText.implicitWidth + 8
                    implicitHeight: 18

                    Text {
                        id: scText
                        anchors.centerIn: parent
                        text: shortcutText
                        font.pixelSize: 9
                        font.family: "monospace"
                        font.bold: true
                        color: colAccent
                    }
                }
            }

            Text {
                text: role
                font.pixelSize: 11
                color: colMutedText
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Modelo: " + model
                    font.pixelSize: 10
                    font.family: "monospace"
                    color: colMutedText
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: "◈ Abrir Terminal"
                    font.pixelSize: 11
                    Material.accent: themeAccent
                    onClicked: spawnClicked()
                }
            }
        }
    }
}
