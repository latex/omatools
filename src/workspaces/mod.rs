use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

use crate::hyprland;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WindowSnapshot {
    pub address: String,
    pub at: (i32, i32),
    pub size: (i32, i32),
    pub workspace: WorkspaceRef,
    pub class: String,
    pub title: String,
    pub pid: i32,
    pub floating: bool,
    #[serde(default)]
    pub initial_class: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WorkspaceRef {
    pub id: i32,
    pub name: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WorkspacePreset {
    pub name: String,
    pub target_workspace: i32,
    pub windows: Vec<PresetWindow>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PresetWindow {
    pub class: String,
    pub command: String,
    pub at: (i32, i32),
    pub size: (i32, i32),
    pub floating: bool,
}

pub fn get_presets_dir() -> Result<PathBuf> {
    let home = std::env::var("HOME").context("HOME environment variable not set")?;
    let path = PathBuf::from(home).join(".config").join("omatools").join("workspaces");
    fs::create_dir_all(&path)?;
    Ok(path)
}

/// Fetch all current clients from Hyprland
pub fn get_active_windows() -> Result<Vec<WindowSnapshot>> {
    let json_str = hyprland::send_command("j/clients")?;
    let windows: Vec<WindowSnapshot> = serde_json::from_str(&json_str)
        .context("Failed to parse Hyprland clients JSON response")?;
    Ok(windows)
}

/// Snapshot windows on a specific workspace
pub fn capture_workspace(workspace_id: i32, preset_name: &str) -> Result<WorkspacePreset> {
    let windows = get_active_windows()?;
    let filtered: Vec<PresetWindow> = windows
        .into_iter()
        .filter(|w| w.workspace.id == workspace_id)
        .map(|w| {
            let cmd = get_process_cmdline(w.pid).unwrap_or_else(|_| w.class.clone());
            PresetWindow {
                class: w.class,
                command: cmd,
                at: w.at,
                size: w.size,
                floating: w.floating,
            }
        })
        .collect();

    let preset = WorkspacePreset {
        name: preset_name.to_string(),
        target_workspace: workspace_id,
        windows: filtered,
    };

    let dir = get_presets_dir()?;
    let file_path = dir.join(format!("{}.json", preset_name));
    let json_data = serde_json::to_string_pretty(&preset)?;
    fs::write(&file_path, json_data)?;

    Ok(preset)
}

/// Read process command line from /proc/<pid>/cmdline
fn get_process_cmdline(pid: i32) -> Result<String> {
    let path = format!("/proc/{}/cmdline", pid);
    let bytes = fs::read(&path)?;
    let parts: Vec<String> = bytes
        .split(|&b| b == 0)
        .filter(|s| !s.is_empty())
        .map(|s| String::from_utf8_lossy(s).to_string())
        .collect();

    if parts.is_empty() {
        anyhow::bail!("Empty cmdline for pid {}", pid);
    }

    Ok(parts.join(" "))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_deserialize_window_sample() {
        let sample = r#"[
            {
                "address": "0x1234",
                "at": [0, 0],
                "size": [1920, 1080],
                "workspace": { "id": 4, "name": "4" },
                "class": "foot",
                "title": "terminal",
                "pid": 12345,
                "floating": false
            }
        ]"#;

        let windows: Vec<WindowSnapshot> = serde_json::from_str(sample).unwrap();
        assert_eq!(windows.len(), 1);
        assert_eq!(windows[0].class, "foot");
        assert_eq!(windows[0].workspace.id, 4);
    }
}
