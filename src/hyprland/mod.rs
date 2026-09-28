use anyhow::{Context, Result};
use std::env;
use std::io::{Read, Write};
use std::os::unix::net::UnixStream;
use std::path::PathBuf;

/// Resolve the path to the Hyprland command socket (.socket.sock)
pub fn get_hyprland_socket_path() -> Result<PathBuf> {
    let signature = env::var("HYPRLAND_INSTANCE_SIGNATURE")
        .context("HYPRLAND_INSTANCE_SIGNATURE environment variable not set. Is Hyprland running?")?;

    let runtime_dir = env::var("XDG_RUNTIME_DIR").unwrap_or_else(|_| {
        let uid = libc_uid();
        format!("/run/user/{}", uid)
    });

    let socket_path = PathBuf::from(runtime_dir)
        .join("hypr")
        .join(&signature)
        .join(".socket.sock");

    if !socket_path.exists() {
        anyhow::bail!("Hyprland socket does not exist at {:?}", socket_path);
    }

    Ok(socket_path)
}

fn libc_uid() -> u32 {
    std::fs::metadata("/proc/self")
        .map(|m| {
            use std::os::unix::fs::MetadataExt;
            m.uid()
        })
        .unwrap_or(1000)
}

/// Send a raw command to Hyprland socket and return the response string
pub fn send_command(command: &str) -> Result<String> {
    let socket_path = get_hyprland_socket_path()?;
    let mut stream = UnixStream::connect(&socket_path)
        .with_context(|| format!("Failed to connect to Hyprland socket at {:?}", socket_path))?;

    stream.write_all(command.as_bytes())?;
    stream.shutdown(std::net::Shutdown::Write)?;

    let mut response = String::new();
    stream.read_to_string(&mut response)?;

    Ok(response)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_uid_resolution() {
        assert!(libc_uid() >= 1000);
    }
}
