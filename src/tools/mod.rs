use anyhow::{Context, Result};
use std::process::Command;

/// Color Picker (integrating hyprpicker)
pub fn run_picker() -> Result<String> {
    let output = Command::new("hyprpicker")
        .arg("-a")
        .output()
        .context("Failed to execute hyprpicker. Is it installed?")?;

    let color = String::from_utf8_lossy(&output.stdout).trim().to_string();
    if color.is_empty() {
        anyhow::bail!("Color picker cancelled by user.");
    }
    Ok(color)
}

/// Text Extractor (OCR)
pub fn run_ocr() -> Result<()> {
    let status = Command::new("omarchy")
        .args(["capture", "text"])
        .status()
        .context("Failed to run 'omarchy capture text'")?;

    if !status.success() {
        anyhow::bail!("OCR capture cancelled or failed.");
    }
    Ok(())
}

/// Awake / Idle Inhibit toggle
pub fn run_awake() -> Result<()> {
    let status = Command::new("omarchy-toggle-idle")
        .status()
        .context("Failed to run omarchy-toggle-idle")?;

    if !status.success() {
        anyhow::bail!("Failed to toggle idle inhibition.");
    }
    Ok(())
}

/// File Locksmith (inspect processes locking a file)
pub fn run_locksmith(path: &str) -> Result<String> {
    let output = Command::new("lsof")
        .arg(path)
        .output()
        .context("Failed to execute lsof. Is it installed?")?;

    let stdout = String::from_utf8_lossy(&output.stdout).to_string();
    if stdout.is_empty() {
        Ok(format!("Nenhum processo bloqueando o arquivo: {}", path))
    } else {
        Ok(stdout)
    }
}

/// Omacut (Video trimmer)
pub fn launch_cut(file: Option<&str>) -> Result<()> {
    let mut cmd = Command::new("omacut");
    if let Some(f) = file {
        cmd.arg(f);
    }
    cmd.spawn().context("Failed to launch omacut")?;
    Ok(())
}

/// Omawrite (Markdown writing app)
pub fn launch_write(file: Option<&str>) -> Result<()> {
    let mut cmd = Command::new("omawrite");
    if let Some(f) = file {
        cmd.arg(f);
    }
    cmd.spawn().context("Failed to launch omawrite")?;
    Ok(())
}

/// Omasnap (Screenshot & Annotations)
pub fn launch_snap() -> Result<()> {
    Command::new("omasnap")
        .spawn()
        .context("Failed to launch omasnap")?;
    Ok(())
}

/// Omacalc (Calculator)
pub fn launch_calc() -> Result<()> {
    Command::new("omacalc")
        .spawn()
        .context("Failed to launch omacalc")?;
    Ok(())
}

/// Flea (File manager)
pub fn launch_flea(path: Option<&str>) -> Result<()> {
    let mut cmd = Command::new("flea");
    if let Some(p) = path {
        cmd.arg(p);
    }
    cmd.spawn().context("Failed to launch flea")?;
    Ok(())
}
