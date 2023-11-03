#![forbid(unsafe_code)]

#[macro_use]
extern crate log;
#[macro_use]
extern crate eyre;
extern crate fs_extra;

mod executor;
mod script;
mod scriptmap;
mod util;
mod cli;

use executor::{
    ExecutionStatus,
    TextReplacement,
};
use scriptmap::ScriptMap;
use cli::Cli;

use eyre::Result;
use clap::Parser;


fn main() -> Result<()>{

    let args: Cli = cli::Cli::parse();

    // create main user scripts directory if it doesn't exist
    let scripts_dir = &util::get_script_dirs()[0];
    std::fs::create_dir_all(scripts_dir);
    // don't fail if the create_dir_all fails, and don't eprint! anything either
    //.wrap_err_with(|| {
    //    format!(
    //        "Failed to create scripts directory in config: {}",
    //        scripts_dir.display()
    //    )
    //})?;
    
    // load scripts
    // TODO: have ScriptMap log any errors loading the scripts
    let mut script_map = ScriptMap::new();

    // read command args
    let script_name = args.script_name.join(" ");
    let script_name_lower = script_name.to_lowercase();
    if args.list_scripts {
        for (name, _) in script_map.0.iter() {
            println!("{}", name);
        }
        std::process::exit(0);
    }
    // if we've filtered for flags like --list-scripts, script_name won't be empty here
    // because Clap is configured with ArgRequiredElseHelp
    let _match;
    let matches: Vec<(&String, &script::Script)> = script_map.0.iter()
            .filter(|(name, _)| name.to_lowercase().starts_with(&script_name_lower))
            .collect();
    if matches.len() != 1 {
        // can't autocomplete the script name. Output the input and then print an error message
        std::io::copy(&mut std::io::stdin(), &mut std::io::stdout());
        if matches.len() == 0 {
            eprintln!("No scripts found with name: {}", script_name);
        } else if matches.len() > 1 {
            // can't pick a script, so output the input and then print options to stderr
            eprintln!("Can't autocomplete script name. Did you mean one of the following?");
            for (name, _) in matches {
                eprintln!("\t{}", name);
            }
        } else {
            unreachable!("matches.len() is not 0, 1, or >1. It is {}", matches.len());
        }
        std::process::exit(1);
    }
    _match = matches[0].0.clone();
    drop(matches);
    
    let s = script_map.0.get_mut(&_match).unwrap();
    let input = std::io::read_to_string(std::io::stdin())?;
    let execution_status: ExecutionStatus = match s.execute(&input, None) {
        Err(_) => {
            std::io::copy(&mut std::io::stdin(), &mut std::io::stdout());
            eprintln!("Failed to execute script: {}", "[placeholder]");
            std::process::exit(1)
        },
        Ok(status) => status,
    };
    let replacement = execution_status.into_replacement();
    let output = match replacement {
        // the script did nothing?? output the input I guess
        TextReplacement::None => {
            std::io::copy(&mut std::io::stdin(), &mut std::io::stdout());
            std::process::exit(1)
        }
        // These shouldn't happen
        TextReplacement::Selection(str) => {
            eprintln!("Warning!! ExecutionStatus.into_replacement returned Selection, when Full was expected");
            str
        },
        TextReplacement::Insert(str_vec) => {
            eprintln!("Warning!! ExecutionStatus.into_replacement returned Selection, when Full was expected");
            str_vec.join("\n")
        }
        TextReplacement::Full(str) => str,
    };
    print!("{}", output);
    std::process::exit(0);

}
