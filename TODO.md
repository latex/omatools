# OmaTools — Roadmap & TODO de Implementação

> **OmaTools**: Suíte completa de utilitários de produtividade para Omarchy / Linux (Wayland / Hyprland), inspirada no Microsoft PowerToys e desenvolvida em **Rust** sob licença **Apache-2.0**.

---

## 🛠️ Catálogo Completo de Ferramentas (PowerToys ➔ OmaTools)

| # | Ferramenta PowerToys | Equivalente OmaTools | Descrição & Arquitetura Linux/Wayland | Status |
|---|----------------------|----------------------|---------------------------------------|--------|
| 1 | **Workspaces** | `omatools workspaces` | Snapshot e restauração de sessões/layouts multi-janela via Hyprland IPC | 🚀 Em Andamento (Sprint 1) |
| 2 | **FancyZones** | `omatools zones` | Zonas de tela customizadas e encaixe magnético de janelas | 📋 Planejado |
| 3 | **Color Picker** | `omatools picker` | Seletor de cores sob o cursor via `wlr-screencopy` com lupa e zoom | 📋 Planejado |
| 4 | **PowerToys Run** | `omatools run` | Launcher ultra-rápido via surface Wayland direta | 📋 Planejado |
| 5 | **Keyboard Manager** | `omatools keys` | Remapeamento de atalhos e macros em nível de evdev / libinput | 📋 Planejado |
| 6 | **Text Extractor** | `omatools ocr` | Recorte de tela + extração OCR direta para a área de transferência | 📋 Planejado |
| 7 | **Awake** | `omatools awake` | Inibidor de idle/sleep via protocolo `ext-idle-inhibit-v1` | 📋 Planejado |
| 8 | **Screen Ruler** | `omatools ruler` | Medição de pixels, caixas delimitadoras e distâncias na tela | 📋 Planejado |
| 9 | **Find My Mouse** | `omatools mouse-find` | Efeito holofote ao redor do cursor ao pressionar tecla dedicada | 📋 Planejado |
| 10 | **Mouse Highlighter** | `omatools mouse-high` | Destaque visual colorido para cliques esquerdo e direito | 📋 Planejado |
| 11 | **Mouse Jump** | `omatools mouse-jump` | Mini-mapa de monitores para teletransporte ágil do cursor | 📋 Planejado |
| 12 | **Mouse Pointer Crosshairs** | `omatools crosshairs` | Mira cartesiana de precisão na tela | 📋 Planejado |
| 13 | **Peek** | `omatools peek` | Pré-visualização instantânea de arquivos (imagens, código, markdown) ao pressionar Espaço | 📋 Planejado |
| 14 | **Paste as Plain Text** | `omatools paste-clean` | Conversão e sanitização de texto rico/HTML para texto puro/markdown na clipboard | 📋 Planejado |
| 15 | **Image Resizer** | `omatools img-resize` | Redimensionamento em lote e otimização rápida de imagens via linha de comando/GUI | 📋 Planejado |
| 16 | **File Locksmith** | `omatools locksmith` | Inspeção instantânea de processos que estão bloqueando arquivos (`sys_openat`, procfs) | 📋 Planejado |
| 17 | **Hosts File Editor** | `omatools hosts` | Gerenciador de `/etc/hosts` com alternância rápida de regras | 📋 Planejado |
| 18 | **Shortcut Guide** | `omatools shortcuts` | Overlay visual na tela com todos os atalhos ativos do Hyprland | 📋 Planejado |
| 19 | **Crop and Lock** | `omatools crop` | Picture-in-picture dinâmico de regiões específicas de janelas | 📋 Planejado |
| 20 | **Quick Accent** | `omatools accent` | Menu rápido de caracteres com acentos ao manter tecla pressionada | 📋 Planejado |
| 21 | **Environment Variables**| `omatools env` | Inspeção e edição de variáveis de ambiente de processos e da sessão Wayland | 📋 Planejado |
| 22 | **File Explorer Add-ons** | `omatools thumbs` | Pré-visualizações e geradores de thumbnails para Flea / gerenciadores de arquivos | 📋 Planejado |
| 23 | **Advanced AI Paste** | `omatools ai-paste` | Transformação de texto na área de transferência via LLM local (Ollama) | 📋 Planejado |

---

## 🏗️ Especificação Técnica em Rust (Edition 2024)

1. **Camada de Comunicação com Hyprland:**
   - Comunicação via Unix Domain Sockets nativos (`std::os::unix::net::UnixStream` / `tokio::net::UnixStream`).
   - Sockets do Hyprland:
     - `/run/user/<UID>/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock` (Comandos)
     - `/run/user/<UID>/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock` (Eventos)
2. **Bibliotecas Principais:**
   - `clap` com derive para interfaces CLI declarativas e auto-documentadas.
   - `serde` / `serde_json` para parsing e serialização de presets.
   - `tokio` para operações assíncronas e escuta de eventos.
   - `anyhow` / `thiserror` para modelagem e propagação robusta de erros.
3. **Licença:**
   - **Apache License 2.0**.
