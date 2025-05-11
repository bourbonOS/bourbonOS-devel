use colored::Colorize;
use std::path::PathBuf;

pub fn generate(session: &super::session::ShellSession) -> String {
    let username = users::get_current_username()
        .map(|s| s.to_string_lossy().into_owned())
        .unwrap_or_else(|| "user".to_string());

    let hostname = hostname::get()
        .map(|s| s.to_string_lossy().into_owned())
        .unwrap_or_else(|_| "localhost".to_string());

    let current_dir = session.current_dir();
    let truncated_path = truncate_path(current_dir);

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

fn truncate_path(path: &PathBuf) -> String {
    let path_str = path.to_string_lossy();
    let home_dir = dirs::home_dir()
        .map(|h| h.to_string_lossy().into_owned())
        .unwrap_or_else(|| "~".to_string());

    if path_str.starts_with(&home_dir) {
        format!("~{}", &path_str[home_dir.len()..])
    } else {
        path_str.into_owned()
    }
}