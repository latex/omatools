use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::process::Command;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentInfo {
    pub id: &'static str,
    pub name: &'static str,
    pub role: &'static str,
    pub model: &'static str,
    pub shortcut: &'static str,
}

pub fn get_available_agents() -> Vec<AgentInfo> {
    vec![
        AgentInfo {
            id: "eng-ia",
            name: "Engenheiro de IA & Kaizen",
            role: "Orquestrador de Infraestrutura, MCP, RAG, Memória & Otimização",
            model: "qwen3.6:27b",
            shortcut: "Alt + 1",
        },
        AgentInfo {
            id: "rust-app",
            name: "Engenheiro Rust 2024",
            role: "Sistemas de Baixo Nível, IPC Hyprland, Tokio & Memory Safety",
            model: "qwen3.6:27b",
            shortcut: "Alt + 2",
        },
        AgentInfo {
            id: "qa-app",
            name: "Auditor de QA 10/10",
            role: "Pirâmide de Testes, Regressão, Fuzzing & Validação Rigorosa",
            model: "gemma4:latest",
            shortcut: "Alt + 3",
        },
        AgentInfo {
            id: "devops-app",
            name: "DevOps & Automações",
            role: "Pipelines CI/CD, Containers Docker, Builds & Infraestrutura",
            model: "qwen3:8b",
            shortcut: "Alt + 4",
        },
        AgentInfo {
            id: "dba-app",
            name: "DBA PostgreSQL & pgvector",
            role: "Modelagem Relacional, Vetores Semânticos, Índices & Tuning",
            model: "qwen3.6:27b",
            shortcut: "Alt + 5",
        },
        AgentInfo {
            id: "iam-app",
            name: "IAM, Segredos & Segurança",
            role: "Zero Plaintext Secrets, Cofre Pass GPG & Conectividade",
            model: "qwen3:8b",
            shortcut: "Alt + 6",
        },
        AgentInfo {
            id: "ui-app",
            name: "UI/UX & Frontend Designer",
            role: "Design Systems, Ergonomia TUI/QML, Temas Dinâmicos & Estética",
            model: "gemma4:latest",
            shortcut: "Alt + 7",
        },
    ]
}

/// Spawn a dedicated terminal running the selected specialized agent
pub fn spawn_agent_terminal(agent_id: &str) -> Result<()> {
    let home = std::env::var("HOME").unwrap_or_else(|_| "/home/leandro".to_string());
    let opencode_path = format!("{}/.local/share/mise/installs/opencode/latest/opencode", home);
    
    let bin = if std::path::Path::new(&opencode_path).exists() {
        opencode_path
    } else {
        "opencode".to_string()
    };

    let title = format!("OmaTools ➔ Agente [{}]", agent_id);
    let mut cmd = Command::new("foot");
    cmd.args(["-T", &title, &bin, "--agent", agent_id]);

    cmd.spawn()
        .with_context(|| format!("Failed to spawn terminal with agent {}", agent_id))?;

    Ok(())
}

/// Spawn Hermes Agent in a dedicated terminal
pub fn spawn_hermes() -> Result<()> {
    let mut cmd = Command::new("foot");
    cmd.args(["-T", "OmaTools ➔ Hermes Agent", "hermes"]);
    cmd.spawn().context("Failed to launch hermes")?;
    Ok(())
}

/// Spawn Antigravity in a dedicated terminal
pub fn spawn_agy() -> Result<()> {
    let mut cmd = Command::new("foot");
    cmd.args(["-T", "OmaTools ➔ Antigravity", "agy"]);
    cmd.spawn().context("Failed to launch agy")?;
    Ok(())
}

/// Transform clipboard content using local LLM (Advanced AI Paste)
pub fn transform_clipboard(task: &str) -> Result<String> {
    // 1. Read text from clipboard
    let paste_out = Command::new("wl-paste")
        .arg("-n")
        .output()
        .context("Failed to read from clipboard via wl-paste")?;

    let input_text = String::from_utf8_lossy(&paste_out.stdout).to_string();
    if input_text.trim().is_empty() {
        anyhow::bail!("Clipboard está vazio.");
    }

    let prompt = format!(
        "Instrução: {}\n\nTexto original:\n\"\"\"\n{}\n\"\"\"\n\nRetorne apenas o texto final resultante, sem preâmbulos, cumprimentos ou explicações adicionais.",
        task, input_text
    );

    // 2. Call local Ollama endpoint synchronously
    let client = reqwest_like_post("http://127.0.0.1:11434/api/generate", &prompt)?;
    
    // 3. Put result back to clipboard
    let mut child = Command::new("wl-copy")
        .stdin(std::process::Stdio::piped())
        .spawn()
        .context("Failed to write to clipboard via wl-copy")?;

    if let Some(mut stdin) = child.stdin.take() {
        use std::io::Write;
        stdin.write_all(client.as_bytes())?;
    }
    child.wait()?;

    Ok(client)
}

fn reqwest_like_post(url: &str, prompt: &str) -> Result<String> {
    let payload = serde_json::json!({
        "model": "default",
        "prompt": prompt,
        "stream": false
    });

    let json_bytes = serde_json::to_vec(&payload)?;

    let mut response_output = Command::new("curl")
        .args(["-s", "-X", "POST", url, "-H", "Content-Type: application/json", "--data-binary", "@-"])
        .stdin(std::process::Stdio::piped())
        .stdout(std::process::Stdio::piped())
        .spawn()?;

    if let Some(mut stdin) = response_output.stdin.take() {
        use std::io::Write;
        stdin.write_all(&json_bytes)?;
    }

    let out = response_output.wait_with_output()?;
    let resp_str = String::from_utf8_lossy(&out.stdout).to_string();

    #[derive(Deserialize)]
    struct OllamaResponse {
        response: Option<String>,
    }

    if let Ok(parsed) = serde_json::from_str::<OllamaResponse>(&resp_str) {
        if let Some(r) = parsed.response {
            return Ok(r.trim().to_string());
        }
    }

    Ok(resp_str)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_available_agents() {
        let agents = get_available_agents();
        assert!(agents.len() >= 6);
        assert_eq!(agents[0].id, "eng-ia");
        assert_eq!(agents[1].id, "rust-app");
    }
}
