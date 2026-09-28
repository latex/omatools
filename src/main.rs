use anyhow::Result;
use clap::{Parser, Subcommand};
use omatools::workspaces;

#[derive(Parser, Debug)]
#[command(
    name = "omatools",
    author = "Leandro Teixeira <leandro.tex@outlook.com>",
    version,
    about = "High-performance PowerToys productivity suite for Omarchy / Hyprland in Rust",
    long_about = "OmaTools is a desktop utility suite bringing the full Microsoft PowerToys experience to Omarchy/Linux under Wayland and Hyprland."
)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Manage, capture, and restore window workspaces presets (PowerToys Workspaces)
    Workspaces {
        #[command(subcommand)]
        action: WorkspaceCommands,
    },
    /// Run quick diagnostic test of Hyprland IPC
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
    /// List all captured workspace presets
    List,
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Workspaces { action } => match action {
            WorkspaceCommands::Capture { workspace, name } => {
                println!("📸 Capturing workspace {} as preset '{}'...", workspace, name);
                let preset = workspaces::capture_workspace(workspace, &name)?;
                println!(
                    "✅ Preset '{}' saved successfully with {} window(s)!",
                    preset.name,
                    preset.windows.len()
                );
            }
            WorkspaceCommands::List => {
                let dir = workspaces::get_presets_dir()?;
                println!("📂 Presets directory: {:?}", dir);
                let entries = std::fs::read_dir(&dir)?;
                for entry in entries.flatten() {
                    println!(" - {}", entry.file_name().to_string_lossy());
                }
            }
        },
        Commands::Status => {
            println!("🔍 Checking Hyprland IPC connection...");
            let windows = workspaces::get_active_windows()?;
            println!("⚡ Hyprland IPC OK! Detected {} active window(s).", windows.len());
            for w in windows {
                println!(
                    "   • [{}] {} (class: '{}', pid: {})",
                    w.workspace.name, w.title, w.class, w.pid
                );
            }
        }
    }

    Ok(())
}
