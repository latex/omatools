use anyhow::Result;
use clap::{Parser, Subcommand};
use omatools::{theme, tools, workspaces};
use std::process::Command as StdCommand;

#[derive(Parser, Debug)]
#[command(
    name = "omatools",
    author = "Leandro Teixeira <leandro.tex@outlook.com>",
    version,
    about = "A unified PowerToys productivity suite for Omarchy / Hyprland in Rust & QtQuick",
    long_about = "OmaTools is a comprehensive desktop utility suite bringing the full Microsoft PowerToys experience to Omarchy/Linux under Wayland and Hyprland, following official Omacom design guidelines."
)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Launch the native OmaTools Control Center (Omacom QtQuick/Material GUI)
    Gui,
    /// Workspaces: Capture, save, and restore multi-window layouts with 1 command
    Workspaces {
        #[command(subcommand)]
        action: WorkspaceCommands,
    },
    /// Color Picker: Sample hex/rgb color under cursor with zoom
    Picker,
    /// Text Extractor: Snipping tool with OCR extracting text straight to clipboard
    Ocr,
    /// Awake: Temporarily toggle or inhibit screen sleep and idle lock
    Awake,
    /// File Locksmith: Find which processes are locking or accessing a file
    Locksmith {
        /// Target file path to inspect
        path: String,
    },
    /// Omacut: Quick video trimmer tool
    Cut {
        /// Optional path to video file
        file: Option<String>,
    },
    /// Omawrite: Minimalist, distraction-free markdown writing
    Write {
        /// Optional path to markdown file
        file: Option<String>,
    },
    /// Omasnap: Native Wayland screenshot and annotation tool
    Snap,
    /// Omacalc: Native calculator tool
    Calc,
    /// Status: Full diagnostic overview of OmaTools and active Hyprland session
    Status,
}

#[derive(Subcommand, Debug)]
enum WorkspaceCommands {
    /// Capture active windows on a workspace into a preset
    Capture {
        /// Workspace number to capture
        #[arg(short, long, default_value_t = 1)]
        workspace: i32,

        /// Preset name to save
        #[arg(short, long)]
        name: String,
    },
    /// Restore a saved workspace preset (switches workspace and launches apps)
    Restore {
        /// Preset name to restore
        name: String,
    },
    /// List all captured workspace presets
    List,
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Some(Commands::Gui) => {
            launch_gui()?;
        }
        Some(Commands::Workspaces { action }) => match action {
            WorkspaceCommands::Capture { workspace, name } => {
                println!("📸 Capturing workspace {} as preset '{}'...", workspace, name);
                let preset = workspaces::capture_workspace(workspace, &name)?;
                println!(
                    "✅ Preset '{}' saved successfully with {} window(s)!",
                    preset.name,
                    preset.windows.len()
                );
            }
            WorkspaceCommands::Restore { name } => {
                println!("🚀 Restoring workspace preset '{}'...", name);
                let preset = workspaces::restore_workspace(&name)?;
                println!(
                    "✅ Workspace {} restored with {} application(s)!",
                    preset.target_workspace,
                    preset.windows.len()
                );
            }
            WorkspaceCommands::List => {
                let presets = workspaces::list_presets()?;
                if presets.is_empty() {
                    println!("📂 Nenhum preset salvo ainda em ~/.config/omatools/workspaces/");
                } else {
                    println!("📂 Presets disponíveis:");
                    for name in presets {
                        println!(" • {}", name);
                    }
                }
            }
        },
        Some(Commands::Picker) => {
            println!("🎯 Clique no pixel desejado na tela...");
            let color = tools::run_picker()?;
            println!("🎨 Cor copiada: {}", color);
        }
        Some(Commands::Ocr) => {
            println!("✂️ Selecione a área da tela para extrair o texto...");
            tools::run_ocr()?;
            println!("📋 Texto extraído copiado para a área de transferência!");
        }
        Some(Commands::Awake) => {
            tools::run_awake()?;
            println!("☕ Estado de inibição de suspensão alternado com sucesso!");
        }
        Some(Commands::Locksmith { path }) => {
            println!("🔍 Inspecionando processos em: {}", path);
            let result = tools::run_locksmith(&path)?;
            println!("{}", result);
        }
        Some(Commands::Cut { file }) => {
            println!("🎬 Abrindo Omacut (Video Trimmer)...");
            tools::launch_cut(file.as_deref())?;
        }
        Some(Commands::Write { file }) => {
            println!("✍️ Abrindo Omawrite (Editor Markdown)...");
            tools::launch_write(file.as_deref())?;
        }
        Some(Commands::Snap) => {
            println!("📸 Abrindo Omasnap (Screenshot & Anotações)...");
            tools::launch_snap()?;
        }
        Some(Commands::Calc) => {
            println!("🧮 Abrindo Omacalc (Calculadora)...");
            tools::launch_calc()?;
        }
        Some(Commands::Status) => {
            print_status_dashboard()?;
        }
        None => {
            // If in graphical desktop, default to opening the Omacom GUI!
            if std::env::var("WAYLAND_DISPLAY").is_ok() || std::env::var("DISPLAY").is_ok() {
                launch_gui()?;
            } else {
                print_welcome_dashboard()?;
            }
        }
    }

    Ok(())
}

fn launch_gui() -> Result<()> {
    let t = theme::load_current_theme().unwrap_or_default();
    println!("🎨 Carregando tema ativo do Omarchy: modo={}, acento={}", t.mode, t.accent);

    // Bind local micro IPC server on 127.0.0.1
    let listener = std::net::TcpListener::bind("127.0.0.1:0")?;
    let port = listener.local_addr()?.port();

    std::thread::spawn(move || {
        use std::io::{Read, Write};
        for stream in listener.incoming() {
            let mut stream = match stream {
                Ok(s) => s,
                Err(_) => break,
            };

            let mut buf = [0u8; 1024];
            let n = match stream.read(&mut buf) {
                Ok(n) if n > 0 => n,
                _ => continue,
            };

            let req = String::from_utf8_lossy(&buf[..n]);
            if let Some(first_line) = req.lines().next() {
                let parts: Vec<&str> = first_line.split_whitespace().collect();
                if parts.len() >= 2 {
                    let path = parts[1];
                    let action = path.trim_start_matches("/action/");
                    match action {
                        "picker" => {
                            std::thread::spawn(|| {
                                let _ = tools::run_picker();
                            });
                        }
                        "ocr" => {
                            std::thread::spawn(|| {
                                let _ = tools::run_ocr();
                            });
                        }
                        "awake" => {
                            let _ = tools::run_awake();
                        }
                        "cut" => {
                            let _ = tools::launch_cut(None);
                        }
                        "write" => {
                            let _ = tools::launch_write(None);
                        }
                        "snap" => {
                            let _ = tools::launch_snap();
                        }
                        "calc" => {
                            let _ = tools::launch_calc();
                        }
                        "flea" => {
                            let _ = tools::launch_flea(None);
                        }
                        "workspaces-save" => {
                            let _ = workspaces::capture_workspace(1, "current");
                        }
                        "workspaces-restore" => {
                            let _ = workspaces::restore_workspace("current");
                        }
                        _ => {}
                    }
                }
            }

            let response = "HTTP/1.1 200 OK\r\nAccess-Control-Allow-Origin: *\r\nContent-Type: text/plain\r\nContent-Length: 2\r\nConnection: close\r\n\r\nOK";
            let _ = stream.write_all(response.as_bytes());
            let _ = stream.flush();
        }
    });

    // Look for ui/Main.qml in standard locations
    let possible_paths = [
        format!("{}/Source/omatools/ui/Main.qml", std::env::var("HOME").unwrap_or_default()),
        format!("{}/Projects/omatools/ui/Main.qml", std::env::var("HOME").unwrap_or_default()),
        format!("{}/.local/share/omatools/ui/Main.qml", std::env::var("HOME").unwrap_or_default()),
        "/usr/share/omatools/ui/Main.qml".to_string(),
    ];

    let qml_path = possible_paths
        .iter()
        .find(|p| std::path::Path::new(p).exists())
        .map(|s| s.as_str())
        .unwrap_or("ui/Main.qml");

    let is_dark = t.mode == "dark";

    let status = StdCommand::new("qml6")
        .arg(qml_path)
        .arg("--")
        .arg(&t.background)
        .arg(&t.foreground)
        .arg(&t.accent)
        .arg(&t.selection)
        .arg(&t.muted)
        .arg(if is_dark { "true" } else { "false" })
        .arg(port.to_string())
        .status()?;

    if !status.success() {
        print_welcome_dashboard()?;
    }

    Ok(())
}

fn print_welcome_dashboard() -> Result<()> {
    println!(r#"
╔═══════════════════════════════════════════════════════════════════╗
║                   🛠️  OMATOOLS — PowerToys Suite                  ║
║                  Linux / Omarchy / Hyprland (Rust)                ║
╚═══════════════════════════════════════════════════════════════════╝

Utilize: omatools <COMANDO>

📌 Módulos Integrados:
  • gui         - Painel de controle visual nativo (Omacom QtQuick/Material)
  • workspaces  - Captura e restaura sessões completas de janelas
  • picker      - Conta-gotas de tela com zoom (Hex/RGB)
  • ocr         - Recorte de tela com extração de texto para clipboard
  • awake       - Inibe suspensão e desligamento de tela temporariamente
  • locksmith   - Descobre qual processo está bloqueando um arquivo
  • cut         - Cortador rápido de vídeos (Omacut)
  • write       - Editor de notas Markdown sem distrações (Omawrite)
  • snap        - Captura de tela com anotações e setas (Omasnap)
  • calc        - Calculadora minimalista (Omacalc)
  • status      - Diagnóstico da sessão Hyprland e janelas ativas

Execute 'omatools --help' para mais detalhes sobre os argumentos.
"#);
    Ok(())
}

fn print_status_dashboard() -> Result<()> {
    println!("🔍 Conectando ao socket IPC do Hyprland...");
    let windows = workspaces::get_active_windows()?;
    println!("⚡ Hyprland IPC OK! Total de {} janela(s) ativa(s):", windows.len());
    for w in windows {
        println!(
            "   • [Workspace {}] {} (Classe: '{}', PID: {})",
            w.workspace.id, w.title, w.class, w.pid
        );
    }

    let presets = workspaces::list_presets()?;
    println!("\n📂 Presets de Workspaces Salvos: {}", presets.len());
    for p in presets {
        println!("   - {}", p);
    }

    println!("\n📦 Ferramentas do Ecossistema Detectadas:");
    for (name, path) in [
        ("hyprpicker", "/usr/bin/hyprpicker"),
        ("omacut", "/usr/bin/omacut"),
        ("omawrite", "/usr/bin/omawrite"),
        ("omasnap", "/usr/bin/omasnap"),
        ("omacalc", "/usr/bin/omacalc"),
        ("flea", "/usr/bin/flea"),
    ] {
        let exists = std::path::Path::new(path).exists();
        let icon = if exists { "✅" } else { "❌" };
        println!("   {} {} ({})", icon, name, path);
    }

    Ok(())
}
