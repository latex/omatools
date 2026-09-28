# OmaTools — Roadmap & TODO de Implementação

> **OmaTools**: Suíte completa de utilitários de produtividade para Omarchy / Linux (Wayland / Hyprland), inspirada no Microsoft PowerToys e arquitetada em **Assembly x86_64** (Linux Syscalls puras + Wayland/Hyprland IPC).

---

## 🛠️ Catálogo Completo de Ferramentas (PowerToys ➔ OmaTools)

| # | Ferramenta PowerToys | Equivalente OmaTools | Descrição & Arquitetura Linux/Wayland | Status |
|---|----------------------|----------------------|---------------------------------------|--------|
| 1 | **Workspaces** | `oma-workspaces` | Snapshot e restauração de sessões/layouts multi-janela via Hyprland IPC | 📋 Planejado (Prioridade 1) |
| 2 | **FancyZones** | `oma-zones` | Zonas de tela customizadas e encaixe magnético de janelas | 📋 Planejado |
| 3 | **Color Picker** | `oma-picker` | Seletor de cores sob o cursor via `wlr-screencopy` com lupa e zoom | 📋 Planejado |
| 4 | **PowerToys Run** | `oma-run` | Launcher ultra-rápido via dmenu/rofi protocol ou surface Wayland direta | 📋 Planejado |
| 5 | **Keyboard Manager** | `oma-keys` | Remapeamento de atalhos e macros em nível de evdev / libinput | 📋 Planejado |
| 6 | **Text Extractor** | `oma-ocr` | Recorte de tela + extração OCR direta para a área de transferência | 📋 Planejado |
| 7 | **Awake** | `oma-awake` | Inibidor de idle/sleep via protocolo `ext-idle-inhibit-v1` | 📋 Planejado |
| 8 | **Screen Ruler** | `oma-ruler` | Medição de pixels, caixas delimitadoras e distâncias na tela | 📋 Planejado |
| 9 | **Find My Mouse** | `oma-mouse-find` | Efeito holofote ao redor do cursor ao pressionar tecla dedicada | 📋 Planejado |
| 10 | **Mouse Highlighter** | `oma-mouse-high` | Destaque visual colorido para cliques esquerdo e direito | 📋 Planejado |
| 11 | **Mouse Jump** | `oma-mouse-jump` | Mini-mapa de monitores para teletransporte ágil do cursor | 📋 Planejado |
| 12 | **Mouse Pointer Crosshairs** | `oma-crosshairs` | Mira cartesiana de precisão na tela | 📋 Planejado |
| 13 | **Peek** | `oma-peek` | Pré-visualização instantânea de arquivos (imagens, código, markdown) ao pressionar Espaço | 📋 Planejado |
| 14 | **Paste as Plain Text** | `oma-paste-clean` | Conversão e sanitização de texto rico/HTML para texto puro/markdown na clipboard | 📋 Planejado |
| 15 | **Image Resizer** | `oma-img-resize` | Redimensionamento em lote e otimização rápida de imagens via linha de comando/GUI | 📋 Planejado |
| 16 | **File Locksmith** | `oma-locksmith` | Inspeção instantânea de processos que estão bloqueando arquivos (`sys_openat`, procfs) | 📋 Planejado |
| 17 | **Hosts File Editor** | `oma-hosts` | Gerenciador de `/etc/hosts` com alternância rápida de regras | 📋 Planejado |
| 18 | **Shortcut Guide** | `oma-shortcuts` | Overlay visual na tela com todos os atalhos ativos do Hyprland | 📋 Planejado |
| 19 | **Crop and Lock** | `oma-crop` | Picture-in-picture dinâmico de regiões específicas de janelas | 📋 Planejado |
| 20 | **Quick Accent** | `oma-accent` | Menu rápido de caracteres com acentos ao manter tecla pressionada | 📋 Planejado |
| 21 | **Environment Variables**| `oma-env` | Inspeção e edição de variáveis de ambiente de processos e da sessão Wayland | 📋 Planejado |
| 22 | **File Explorer Add-ons** | `oma-thumbs` | Pré-visualizações e geradores de thumbnails para Flea / gerenciadores de arquivos | 📋 Planejado |
| 23 | **Advanced AI Paste** | `oma-ai-paste` | Transformação de texto na área de transferência via LLM local (Ollama) | 📋 Planejado |

---

## 🏗️ Especificação Técnica & Arquitetura em Assembly x86_64

1. **Camada de Syscalls Diretas (Zero Overhead):**
   - Comunicação via sockets UNIX (`sys_socket`, `sys_connect`, `sys_sendto`, `sys_recvfrom`).
   - Sockets IPC do Hyprland:
     - `/run/user/1000/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock` (Comandos)
     - `/run/user/1000/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock` (Eventos em tempo real)
2. **Wayland Wire Protocol em ASM:**
   - Mensagens binárias serialized diretamente para o socket do compositor (`WAYLAND_DISPLAY`).
   - Gerenciamento de buffers de memória compartilhada (`memfd_create`, `sys_mmap`).
3. **Padrão de Compilação & Ferramental:**
   - Montador: `nasm` / `as` (GNU Assembler) com sintaxe Intel ou AT&T.
   - Linker: `ld` gerando binários ELF de poucos kilobytes, sem dependência do libc runtime quando cabível.
   - Orquestração de testes e build: `Makefile`.

---

## 📋 Próximos Passos (Sprint 1)
- [ ] Implementar `oma-workspaces` (Fase 1: CLI em Assembly x86_64 para capturar o dump de janelas do Hyprland e gerar o script de restauração).
- [ ] Implementar `oma-awake` (Inibidor de idle via socket Wayland puro em ASM).
- [ ] Configurar suíte de testes com validação multiespecialista (Metodologia Poker Prompt 10/10).
