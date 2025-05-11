use std::env;
use rustyline::error::ReadlineError;
use rustyline::{Editor, Result};

mod container;
mod prompt;
mod session;
mod utils;

use container::ContainerManager;
use session::ShellSession;

fn main() -> Result<()> {
    let args: Vec<String> = env::args().collect();
    let host_mode = args.contains(&String::from("--host"));

    let container_manager = ContainerManager::new();
    let mut session = ShellSession::new(
        host_mode,
        if host_mode { None } else { Some(container_manager.unique_id()) }
    );

    let mut rl = Editor::<()>::new()?;
    utils::load_history(&mut rl)?;

    loop {
        let prompt = prompt::generate(&session);
        let readline = rl.readline(&prompt);

        match readline {
            Ok(line) => {
                let line = line.trim();
                if line.is_empty() {
                    continue;
                }

                if line == "exit" {
                    println!("Goodbye!");
                    break;
                }

                // Handle history without using ? on bool
                if line != "clear" {
                    if rl.history().last().map(|s| s.as_str()) != Some(line) {
                        if !rl.add_history_entry(line) {
                            eprintln!("Failed to add history entry");
                        }
                    }
                }

                let output = session.execute(line);
                print!("{}", output);
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