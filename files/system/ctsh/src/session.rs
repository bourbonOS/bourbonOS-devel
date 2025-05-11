use std::io::{BufRead, BufReader, Write};
use std::process::{ChildStdin, ChildStdout, Command, Stdio};
use std::path::PathBuf;
use dirs;

pub struct ShellSession {
    stdin: ChildStdin,
    stdout: BufReader<ChildStdout>,
    current_dir: PathBuf,
    host_mode: bool,
}

impl ShellSession {
    pub fn new(host_mode: bool, container_id: Option<&str>) -> Self {
        let mut cmd = if host_mode {
            Command::new("bash")
        } else {
            let mut cmd = Command::new("podman");
            cmd.args(["exec", "-it", container_id.unwrap(), "bash"]);
            cmd
        };

        let home_dir = dirs::home_dir().unwrap_or_else(|| PathBuf::from("/"));
        
        let mut bash = cmd
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::inherit())
            .current_dir(&home_dir)
            .spawn()
            .expect("Failed to start bash");

        Self {
            stdin: bash.stdin.take().unwrap(),
            stdout: BufReader::new(bash.stdout.take().unwrap()),
            current_dir: home_dir,
            host_mode,
        }
    }

    pub fn execute(&mut self, command: &str) -> String {
        let parts: Vec<&str> = command.split_whitespace().collect();
        if parts.is_empty() {
            return String::new();
        }

        match parts[0] {
            "exit" => String::from("Goodbye!\n"),
            "clear" => String::from("\x1B[2J\x1B[H"), // ANSI clear screen
            "subsys" | "dnf" | "dnf5" | "exec" if !self.host_mode => {
                String::from("Operation not permitted\n")
            },
            "cd" => {
                let _ = self.execute_raw(command);
                let new_dir = self.execute_raw("pwd");
                self.current_dir = PathBuf::from(new_dir.trim());
                String::new()
            },
            _ => self.execute_raw(command),
        }
    }

    fn execute_raw(&mut self, command: &str) -> String {
        let is_ls = command.starts_with("ls") && !command.contains(" -");
        let cmd_str = if is_ls {
            format!("{}; echo --CTSH-END--", command)
        } else {
            let cols = termsize::get().map(|s| s.cols).unwrap_or(80);
            format!("COLUMNS={} {}; echo --CTSH-END--", cols, command)
        };

        writeln!(self.stdin, "{}", cmd_str).unwrap();
        
        let mut output = String::new();
        loop {
            let mut line = String::new();
            self.stdout.read_line(&mut line).unwrap();
            if line.contains("--CTSH-END--") {
                break;
            }
            output.push_str(&line);
        }
        output
    }

    pub fn current_dir(&self) -> &PathBuf {
        &self.current_dir
    }
}