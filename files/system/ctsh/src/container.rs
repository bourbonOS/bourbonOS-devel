use std::fs;
use std::path::PathBuf;
use rand::{distributions::Alphanumeric, Rng};

pub struct ContainerManager {
    unique_id: String,
    container_path: PathBuf,
}

impl ContainerManager {
    pub fn new() -> Self {
        let unique_id: String = rand::thread_rng()
            .sample_iter(&Alphanumeric)
            .take(6)
            .map(|c| c as char)
            .collect();

        let container_path = Self::create_container_file(&unique_id);

        if !container_path.exists() {
            if let Err(err) = fs::write(&container_path, "subsystem") {
                eprintln!("Error creating container file: {}", err);
            }
        }

        Self {
            unique_id,
            container_path,
        }
    }

    pub fn unique_id(&self) -> &str {
        &self.unique_id
    }

    pub fn cleanup(&self) {
        if let Err(err) = fs::remove_file(&self.container_path) {
            eprintln!("Error removing container file: {}", err);
        }
    }

    fn create_container_file(unique_id: &str) -> PathBuf {
        dirs::cache_dir().unwrap_or_else(|| {
            let mut home = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
            home.push(".cache");
            if !home.exists() {
                let _ = fs::create_dir_all(&home);
            }
            home
        }).join(format!("container.{}", unique_id))
    }
}