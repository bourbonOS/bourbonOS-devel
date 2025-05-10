use dirs;
use rustyline::{Editor, Helper, Result};
use std::path::PathBuf;

pub fn load_history<H: Helper>(rl: &mut Editor<H>) -> Result<()> {
    let history_path = history_file_path();
    if history_path.exists() {
        rl.load_history(&history_path)?;
    }
    Ok(())
}

pub fn save_history<H: Helper>(rl: &mut Editor<H>) -> Result<()> {
    let history_path = history_file_path();
    rl.save_history(&history_path)?;
    Ok(())
}

fn history_file_path() -> PathBuf {
    dirs::home_dir()
        .map(|mut path| {
            path.push(".ctsh_history");
            path
        })
        .unwrap_or_else(|| PathBuf::from(".ctsh_history"))
}