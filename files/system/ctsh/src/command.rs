use std::env;
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::io::Write;
use which::which;

use crate::variables;
use crate::container::ContainerManager;

pub struct CommandProcessor {
    host_mode: bool,
    unique_id: String,
}

impl CommandProcessor {
    pub fn new(host_mode: bool, unique_id: String) -> Self {
        Self { host_mode, unique_id }
    }

    pub fn process(&self, command: &str) -> bool {
        let command = command.trim();
        if command.is_empty() {
            return true;
        }

        if command == "exit" {
            println!("Goodbye!");
            return false;
        }

        let expanded_command = variables::expand(command);
        let parts: Vec<&str> = expanded_command.split_whitespace().collect();
        
        match parts[0] {
            "cd" => self.handle_cd(&parts),
            "container" | "baseos" | "transit" | "synergy" => self.execute_special_command(&parts),
            "subsys" | "dnf" | "dnf5" | "bash" | "sh" | "exec" => {
                println!("Operation not permitted");
                true
            },
            _ => self.execute_generic_command(&parts),
        }
    }

    fn handle_cd(&self, parts: &[&str]) -> bool {
        let new_dir = if parts.len() < 2 {
            dirs::home_dir().unwrap_or_else(|| PathBuf::from("/"))
        } else {
            PathBuf::from(variables::expand(parts[1]))
        };

        if let Err(e) = env::set_current_dir(&new_dir) {
            eprintln!("cd: {}: {}", new_dir.display(), e);
        }
        true
    }

    fn execute_special_command(&self, parts: &[&str]) -> bool {
        let cmd = match parts[0] {
            "container" => "/usr/libexec/ctsh/container",
            "baseos" => "/usr/libexec/ctsh/baseos",
            "transit" => "/usr/libexec/ctsh/transit",
            "synergy" => "/usr/bin/synergy",
            _ => return true,
        };

        let mut child = match Command::new(cmd)
            .args(&parts[1..])
            .stdin(Stdio::piped())
            .stdout(Stdio::inherit())
            .stderr(Stdio::inherit())
            .spawn() 
        {
            Ok(child) => child,
            Err(e) => {
                eprintln!("Failed to execute command: {}", e);
                return true;
            }
        };

        if let Some(mut stdin) = child.stdin.take() {
            if let Err(e) = stdin.write_all(self.unique_id.as_bytes()) {
                eprintln!("Failed to write to stdin: {}", e);
            }
        }

        match child.wait() {
            Ok(_) => true,
            Err(e) => {
                eprintln!("Failed to wait for command: {}", e);
                true
            }
        }
    }

    fn execute_generic_command(&self, parts: &[&str]) -> bool {
        let cmd = parts[0];
        
        if which(cmd).is_ok() {
            if self.host_mode {
                self.execute_host_command(cmd, &parts[1..])
            } else {
                self.execute_container_command(cmd, &parts[1..])
            }
        } else {
            println!("Command not found: {}", cmd);
            true
        }
    }

    fn execute_host_command(&self, cmd: &str, args: &[&str]) -> bool {
        match Command::new(cmd)
            .args(args)
            .stdin(Stdio::inherit())
            .stdout(Stdio::inherit())
            .stderr(Stdio::inherit())
            .status() 
        {
            Ok(_) => true,
            Err(e) => {
                eprintln!("Failed to execute command: {}", e);
                true
            }
        }
    }

    fn execute_container_command(&self, cmd: &str, args: &[&str]) -> bool {
        let container = ContainerManager::get_container_value_by_id(&self.unique_id);
        let command_with_args = if !args.is_empty() {
            format!("{} {}", cmd, args.join(" "))
        } else {
            cmd.to_string()
        };

        let current_dir = env::current_dir().unwrap_or_else(|_| PathBuf::from("/"));
        let current_dir_str = current_dir.to_string_lossy();

        if container == "subsystem" {
            let uid = Command::new("id")
                .arg("-u")
                .output()
                .map(|output| String::from_utf8_lossy(&output.stdout).trim().to_string())
                .unwrap_or_else(|_| String::from("1000"));

            let home = env::var("HOME").unwrap_or_else(|_| String::from("/home/user"));
            let user = env::var("USER").unwrap_or_else(|_| String::from("user"));

            Command::new("podman")
                .args([
                    "exec", "-it", 
                    "--user", &uid,
                    "--workdir", &current_dir_str,
                    "-e", &format!("HOME={}", home),
                    "-e", &format!("USER={}", user),
                    &container,
                    "sh", "-c", &command_with_args
                ])
                .stdin(Stdio::inherit())
                .stdout(Stdio::inherit())
                .stderr(Stdio::inherit())
                .status()
                .map(|_| true)
                .unwrap_or_else(|e| {
                    eprintln!("Failed to execute command in container: {}", e);
                    true
                })
        } else {
            Command::new("distrobox-enter")
                .args([
                    "--name", &container,
                    "--",
                ])
                .arg(&command_with_args)
                .stdin(Stdio::inherit())
                .stdout(Stdio::inherit())
                .stderr(Stdio::inherit())
                .status()
                .map(|_| true)
                .unwrap_or_else(|e| {
                    eprintln!("Failed to execute command in container: {}", e);
                    true
                })
        }
    }
}