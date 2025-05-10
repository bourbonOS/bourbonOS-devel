use regex::Regex;
use dirs;
use std::env;

pub fn expand(input: &str) -> String {
    let mut result = input.to_string();

    // Handle ${VAR} style variables
    let braced_var_regex = Regex::new(r"\$\{([A-Za-z_][A-Za-z0-9_]*)\}").unwrap();
    while let Some(caps) = braced_var_regex.captures(&result) {
        let var_name = caps.get(1).unwrap().as_str();
        let replacement = env::var(var_name).unwrap_or_else(|_| String::new());
        result = braced_var_regex.replace(&result, &replacement).to_string();
    }

    // Handle $VAR style variables
    let simple_var_regex = Regex::new(r"\$([A-Za-z_][A-Za-z0-9_]*)").unwrap();
    while let Some(caps) = simple_var_regex.captures(&result) {
        let var_name = caps.get(1).unwrap().as_str();
        let replacement = env::var(var_name).unwrap_or_else(|_| String::new());
        result = simple_var_regex.replace(&result, &replacement).to_string();
    }

    // Handle ~ expansion
    if result.contains('~') {
        if let Some(home) = dirs::home_dir() {
            let home_str = home.to_string_lossy();
            let tilde_regex = Regex::new(r"(^|\s)~(/|$)").unwrap();
            result = tilde_regex.replace_all(&result, format!("$1{}$2", home_str)).to_string();
        }
    }

    result
}