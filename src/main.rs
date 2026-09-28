use anyhow::Result;
use clap::{Parser, Subcommand};
use omatools::{tools, workspaces};

#[derive(Parser, Debug)]
#[command(
    name = "omatools",
    author = "Leandro Teixeira <leandro.tex@outlook.com>",
    version,
    about = "A unified PowerToys productivity suite for Omarchy / Hyprland in Rust",
    long_about = "OmaTools is a comprehensive desktop utility suite bringing the full Microsoft PowerToys experience to Omarchy/Linux under Wayland and Hyprland."
)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand, Debug)]
enum Commands {
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
            print_welcome_dashboard()?;
        }
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
