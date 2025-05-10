use std::env;
use rustyline::error::ReadlineError;
use rustyline::{Editor, Result};

mod container;
mod prompt;
mod command;
mod utils;
mod variables;

use container::ContainerManager;
use command::CommandProcessor;

fn main() -> Result<()> {
    let args: Vec<String> = env::args().collect();
    let host_mode = args.contains(&String::from("--host"));

    let container_manager = ContainerManager::new();
    let command_processor = CommandProcessor::new(  // Removed mut
        host_mode,
        container_manager.unique_id().to_string()
    );

    let mut rl = Editor::<()>::new()?;
    utils::load_history(&mut rl)?;

    loop {
        let prompt = prompt::generate();
        let readline = rl.readline(&prompt);

        match readline {
            Ok(line) => {
                if !line.trim().is_empty() {
                    if !rl.add_history_entry(line.as_str()) {
                        eprintln!("Failed to add history entry");
                    }
                }

                if !command_processor.process(&line) {
                    break;
                }
            }
            Err(ReadlineError::Interrupted) => {
                println!("^C");
                continue;
            }
            Err(ReadlineError::Eof) => {
                println!("exit");
                break;
            }
            Err(err) => {
                eprintln!("Error: {}", err);
                break;
            }
        }
    }

    utils::save_history(&mut rl)?;
    container_manager.cleanup();
    Ok(())
}