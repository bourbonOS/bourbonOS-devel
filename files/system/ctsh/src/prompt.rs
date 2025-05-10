use std::env;
use std::path::{Path, PathBuf};
use colored::Colorize;
use dirs;
use hostname;
use path_absolutize::Absolutize;
use users;

pub fn generate() -> String {
    let username = match users::get_current_username() {
        Some(name) => name.to_string_lossy().into_owned(),
        None => String::from("user"),
    };

    let hostname = match hostname::get() {
        Ok(name) => name.to_string_lossy().into_owned(),
        Err(_) => String::from("localhost"),
    };

    let current_dir = match env::current_dir() {
        Ok(dir) => dir,
        Err(_) => PathBuf::from("."),
    };

    let truncated_path = truncate_path(&current_dir);

    format!(
        "{}{}@{}{}-{}{}{}$ ",
        "[".green(),
        username.blue(),
        hostname.blue(),
        "]".green(),
        "[".green(),
        truncated_path.blue(),
        "]".green()
    )
}

fn truncate_path(path: &Path) -> String {
    let abs_path = match path.absolutize() {
        Ok(p) => p.to_path_buf(),
        Err(_) => return path.display().to_string(),
    };

    let path_str = abs_path.to_string_lossy().into_owned();
    let home_dir = match dirs::home_dir() {
        Some(dir) => dir.to_string_lossy().into_owned(),
        None => return path_str,
    };

    let mut path_display = path_str.clone();
    if path_str.starts_with(&home_dir) {
        path_display = format!("~{}", &path_str[home_dir.len()..]);
    }

    let path_parts: Vec<&str> = path_display.split('/').collect();
    if path_parts.len() <= 3 {
        return path_display;
    }

    let len = path_parts.len();
    let last_two = if len >= 2 {
        format!("{}/{}", path_parts[len - 2], path_parts[len - 1])
    } else {
        path_parts[len - 1].to_string()
    };

    if path_display.starts_with('~') {
        format!("~/.../{}", last_two)
    } else {
        format!("/.../{}", last_two)
    }
}