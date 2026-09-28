use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use crate::hyprland;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ZoneLayout {
    Split2,       // 2 equal columns (50% | 50%)
    PriorityGrid, // 3 columns (25% | 50% | 25%)
    Columns3,     // 3 equal columns (33.3% | 33.3% | 33.3%)
    Grid2x2,      // 4 quadrants (Top-Left, Top-Right, Bottom-Left, Bottom-Right)
    Rows2,        // 2 rows (50% top | 50% bottom)
    Focus,        // Centered focus window (75% w, 85% h)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Rect {
    pub x: i32,
    pub y: i32,
    pub width: i32,
    pub height: i32,
}

#[derive(Debug, Clone, Deserialize)]
pub struct HyprMonitor {
    pub id: i64,
    pub x: i32,
    pub y: i32,
    pub width: i32,
    pub height: i32,
    pub scale: f64,
    pub transform: i32,
    pub focused: bool,
    pub reserved: [i32; 4], // [left, top, right, bottom]
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct HyprActiveWindow {
    address: String,
    monitor: i64,
    floating: bool,
    pinned: bool,
    at: [i32; 2],
    size: [i32; 2],
    title: String,
    class: String,
}

/// Fetch active window details from Hyprland
fn get_active_window() -> Result<HyprActiveWindow> {
    let json_str = hyprland::send_command("j/activewindow\n")
        .context("Failed to get active window from Hyprland")?;
    let win: HyprActiveWindow = serde_json::from_str(&json_str)
        .context("Failed to parse active window JSON")?;
    Ok(win)
}

/// Fetch all monitors from Hyprland
fn get_monitors() -> Result<Vec<HyprMonitor>> {
    let json_str = hyprland::send_command("j/monitors\n")
        .context("Failed to get monitors from Hyprland")?;
    let monitors: Vec<HyprMonitor> = serde_json::from_str(&json_str)
        .context("Failed to parse monitors JSON")?;
    Ok(monitors)
}

/// Calculate zones for a given monitor and layout with gap padding
pub fn calculate_zones(mon: &HyprMonitor, layout: ZoneLayout, gap: i32) -> Vec<Rect> {
    let scale = if mon.scale <= 0.0 { 1.0 } else { mon.scale };
    
    // Check if monitor is rotated 90 or 270 degrees (transform 1 or 3)
    let (phys_w, phys_h) = if mon.transform == 1 || mon.transform == 3 {
        (mon.height, mon.width)
    } else {
        (mon.width, mon.height)
    };

    let mon_w = (phys_w as f64 / scale).round() as i32;
    let mon_h = (phys_h as f64 / scale).round() as i32;

    let usable_x = mon.x + mon.reserved[0] + gap;
    let usable_y = mon.y + mon.reserved[1] + gap;
    let usable_w = mon_w - mon.reserved[0] - mon.reserved[2] - (gap * 2);
    let usable_h = mon_h - mon.reserved[1] - mon.reserved[3] - (gap * 2);

    match layout {
        ZoneLayout::Split2 => {
            let half_w = (usable_w - gap) / 2;
            vec![
                Rect { x: usable_x, y: usable_y, width: half_w, height: usable_h },
                Rect { x: usable_x + half_w + gap, y: usable_y, width: half_w, height: usable_h },
            ]
        }
        ZoneLayout::PriorityGrid => {
            let side_w = (usable_w as f64 * 0.25).round() as i32 - gap;
            let center_w = usable_w - (side_w * 2) - (gap * 2);
            vec![
                Rect { x: usable_x, y: usable_y, width: side_w, height: usable_h },
                Rect { x: usable_x + side_w + gap, y: usable_y, width: center_w, height: usable_h },
                Rect { x: usable_x + side_w + gap + center_w + gap, y: usable_y, width: side_w, height: usable_h },
            ]
        }
        ZoneLayout::Columns3 => {
            let col_w = (usable_w - (gap * 2)) / 3;
            vec![
                Rect { x: usable_x, y: usable_y, width: col_w, height: usable_h },
                Rect { x: usable_x + col_w + gap, y: usable_y, width: col_w, height: usable_h },
                Rect { x: usable_x + (col_w + gap) * 2, y: usable_y, width: col_w, height: usable_h },
            ]
        }
        ZoneLayout::Grid2x2 => {
            let half_w = (usable_w - gap) / 2;
            let half_h = (usable_h - gap) / 2;
            vec![
                Rect { x: usable_x, y: usable_y, width: half_w, height: half_h },
                Rect { x: usable_x + half_w + gap, y: usable_y, width: half_w, height: half_h },
                Rect { x: usable_x, y: usable_y + half_h + gap, width: half_w, height: half_h },
                Rect { x: usable_x + half_w + gap, y: usable_y + half_h + gap, width: half_w, height: half_h },
            ]
        }
        ZoneLayout::Rows2 => {
            let half_h = (usable_h - gap) / 2;
            vec![
                Rect { x: usable_x, y: usable_y, width: usable_w, height: half_h },
                Rect { x: usable_x, y: usable_y + half_h + gap, width: usable_w, height: half_h },
            ]
        }
        ZoneLayout::Focus => {
            let focus_w = (usable_w as f64 * 0.75).round() as i32;
            let focus_h = (usable_h as f64 * 0.85).round() as i32;
            let offset_x = usable_x + (usable_w - focus_w) / 2;
            let offset_y = usable_y + (usable_h - focus_h) / 2;
            vec![
                Rect { x: offset_x, y: offset_y, width: focus_w, height: focus_h },
            ]
        }
    }
}

/// Snap active window into a specified zone index (0-indexed or 1-indexed)
pub fn snap_active_window(layout: ZoneLayout, zone_index: usize) -> Result<()> {
    let win = get_active_window()?;
    let monitors = get_monitors()?;

    let mon = monitors
        .iter()
        .find(|m| m.id == win.monitor)
        .or_else(|| monitors.iter().find(|m| m.focused))
        .context("Could not find monitor for active window")?;

    let zones = calculate_zones(mon, layout, 10);
    if zones.is_empty() {
        anyhow::bail!("Layout has no zones configured");
    }

    let target_idx = zone_index.clamp(0, zones.len() - 1);
    let target = &zones[target_idx];

    // Ensure window is floating so we can position and resize freely
    if !win.floating {
        let _ = hyprland::send_command("/dispatch setfloating active\n");
    }

    // Move window
    let move_cmd = format!(
        "/dispatch movewindowpixel exact {} {},address:{}\n",
        target.x, target.y, win.address
    );
    hyprland::send_command(&move_cmd)?;

    // Resize window
    let resize_cmd = format!(
        "/dispatch resizewindowpixel exact {} {},address:{}\n",
        target.width, target.height, win.address
    );
    hyprland::send_command(&resize_cmd)?;

    Ok(())
}

/// Toggle Always on Top (Pin & Float) on active window
pub fn toggle_always_on_top() -> Result<bool> {
    let win = get_active_window()?;
    if !win.floating {
        let _ = hyprland::send_command("/dispatch setfloating active\n");
    }
    let _ = hyprland::send_command("/dispatch pin active\n");
    
    // Check new state
    let updated = get_active_window()?;
    Ok(updated.pinned)
}

/// Paste as Plain Text (PowerToys Win+Ctrl+Alt+V equivalent)
pub fn paste_as_plain_text() -> Result<()> {
    // 1. Read clipboard as text using wl-paste
    let paste_out = std::process::Command::new("wl-paste")
        .arg("-n")
        .arg("--no-newline")
        .output()
        .context("Failed to execute wl-paste")?;

    let plain_text = String::from_utf8_lossy(&paste_out.stdout).to_string();
    if plain_text.is_empty() {
        return Ok(());
    }

    // 2. Put back to clipboard strictly as text/plain
    let mut child = std::process::Command::new("wl-copy")
        .arg("-t")
        .arg("text/plain")
        .stdin(std::process::Stdio::piped())
        .spawn()
        .context("Failed to spawn wl-copy")?;

    if let Some(mut stdin) = child.stdin.take() {
        use std::io::Write;
        stdin.write_all(plain_text.as_bytes())?;
    }
    child.wait()?;

    // 3. Simulate Ctrl+V paste via wtype if available
    if std::path::Path::new("/usr/bin/wtype").exists() {
        let _ = std::process::Command::new("wtype")
            .args(["-M", "ctrl", "-k", "v", "-m", "ctrl"])
            .status();
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculate_zones_split2() {
        let mon = HyprMonitor {
            id: 0,
            x: 0,
            y: 0,
            width: 1920,
            height: 1080,
            scale: 1.0,
            transform: 0,
            focused: true,
            reserved: [0, 0, 0, 0],
        };

        let zones = calculate_zones(&mon, ZoneLayout::Split2, 10);
        assert_eq!(zones.len(), 2);
        assert_eq!(zones[0].x, 10);
        assert_eq!(zones[0].y, 10);
        assert!(zones[0].width > 900);
        assert_eq!(zones[1].x, zones[0].x + zones[0].width + 10);
    }

    #[test]
    fn test_calculate_zones_priority_grid() {
        let mon = HyprMonitor {
            id: 0,
            x: 0,
            y: 0,
            width: 3840,
            height: 2160,
            scale: 1.0,
            transform: 0,
            focused: true,
            reserved: [0, 26, 0, 0],
        };

        let zones = calculate_zones(&mon, ZoneLayout::PriorityGrid, 10);
        assert_eq!(zones.len(), 3);
        // Center zone must be larger than left and right
        assert!(zones[1].width > zones[0].width);
        assert!(zones[1].width > zones[2].width);
    }

    #[test]
    fn test_calculate_zones_grid2x2() {
        let mon = HyprMonitor {
            id: 0,
            x: 0,
            y: 0,
            width: 1920,
            height: 1080,
            scale: 1.0,
            transform: 0,
            focused: true,
            reserved: [0, 0, 0, 0],
        };

        let zones = calculate_zones(&mon, ZoneLayout::Grid2x2, 10);
        assert_eq!(zones.len(), 4);
    }
}
