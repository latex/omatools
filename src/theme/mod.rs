use anyhow::{Context, Result};
use std::fs;
use std::path::PathBuf;

#[derive(Debug, Clone)]
pub struct OmarchyTheme {
    pub mode: String,
    pub background: String,
    pub foreground: String,
    pub accent: String,
    pub selection: String,
    pub muted: String,
}

impl Default for OmarchyTheme {
    fn default() -> Self {
        Self {
            mode: "dark".to_string(),
            background: "#1e1e2e".to_string(),
            foreground: "#cdd6f4".to_string(),
            accent: "#89b4fa".to_string(),
            selection: "#313244".to_string(),
            muted: "#6c7086".to_string(),
        }
    }
}

pub fn load_current_theme() -> Result<OmarchyTheme> {
    let home = std::env::var("HOME").context("HOME not set")?;
    let path = PathBuf::from(home)
        .join(".local")
        .join("state")
        .join("omarchy")
        .join("current")
        .join("theme")
        .join("colors.toml");

    if !path.exists() {
        return Ok(OmarchyTheme::default());
    }

    let content = fs::read_to_string(&path)?;
    let mut theme = OmarchyTheme::default();

    for line in content.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }

        if let Some((key, val)) = line.split_once('=') {
            let key = key.trim();
            let val = val.trim().trim_matches('"').trim_matches('\'');
            match key {
                "mode" => theme.mode = val.to_string(),
                "background" => theme.background = val.to_string(),
                "foreground" => theme.foreground = val.to_string(),
                "accent" => theme.accent = val.to_string(),
                "selection" => theme.selection = val.to_string(),
                "muted" => theme.muted = val.to_string(),
                _ => {}
            }
        }
    }

    Ok(theme)
}
