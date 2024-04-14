#![forbid(unsafe_code)]

extern crate boop;
extern crate clap;
extern crate eyre;
extern crate fs_extra;

mod cli;

use boop::executor::TextReplacement;
use boop::script;
use boop::scriptmap::ScriptMap;
use boop::util;
use cli::Cli;

use eyre::{
    Result,
    Error,
};
use clap::Parser;
use std::io::{
    Write, Seek, SeekFrom,
};
use std::fs::File;
//use neovim_lib::{Neovim, NeovimApi, Session};
//
//enum MsgPackMessages {
//    Boop,
//    Unknown(String),
//}
//
//impl From<String> for MsgPackMessages {
//    fn from(event: String) -> Self {
//        match &event[..] {
//            "boop" => MsgPackMessages::Boop,
//            _ => MsgPackMessages::Unknown,
//        }
//    }
//}

fn open_output_file(path: String) -> Result<File> {
    if path == "" {
        return Err(Error::msg("path is empty"));
    }
    let output_file = File::create(path.clone())?;
    Ok(output_file)
}

fn main() -> Result<()>{
    let args: Cli = cli::Cli::parse();
    // read command args
    let mut script_name = args.script_name.join(" ");

    // create main user scripts directory if it doesn't exist
    let scripts_dir = &util::get_script_dirs()[0];
    let _ = std::fs::create_dir_all(scripts_dir);
    // don't fail if the create_dir_all fails, but should probably eprint! it
    //.wrap_err_with(|| {
    //    format!(
    //        "Failed to create scripts directory in config: {}",
    //        scripts_dir.display()
    //    )
    //})?;
    // load scripts
    // TODO: have ScriptMap log any errors loading the scripts
    let mut script_map = ScriptMap::new();

    /* op_mode: --list-scripts */
    if args.list_scripts {
        for (name, _) in script_map.0.iter() {
            println!("{}", name);
        }
        std::process::exit(0);
    }

    /* op_mode: --rpc */
    if args.rpc {
        eprintln!("Error: RPC mode not implemented yet");
        //let mut session = Session::new_parent().unwrap();
        //let receiver = nvim.session.start_event_loop_channel();
        //let mut nvim = Neovim::new(session);
        //for (event_name, values) in receiver {
        //    match MsgPackMessages::from(event_name) {
        //        MsgPackMessages::Boop => {
        //            let output_text = RunScript(script_name, input_text);
        //        }

        //        MsgPackMessages::Unknown => {
        //        }
        //    }
        //}
        std::process::exit(0);
    }

    /* op_mode: <SCRIPT_NAME> */
    let matches: Vec<(&String, &script::Script)> = script_map.0.iter()
            .filter(|(name, _)| name.to_lowercase().starts_with(&script_name.to_lowercase()))
            .collect();
    if matches.len() != 1 {
        // can't find the script. Output the input and then eprint an error message
        _ = std::io::copy(&mut std::io::stdin(), &mut std::io::stdout());
        if matches.len() == 0 {
            eprintln!("No scripts found with name: {}", script_name);
        } else if matches.len() > 1 {
            eprintln!("Can't autocomplete script name. Did you mean one of the following?");
            for (name, _) in matches {
                eprintln!("\t{}", name);
            }
        } else {
            unreachable!("matches.len() is not 0, 1, or >1. It is {}", matches.len());
        }
        std::process::exit(1);
    }
    script_name = matches[0].0.clone();
    let script = script_map.0.get_mut(&script_name).unwrap();
    let input = std::io::read_to_string(std::io::stdin())?;
    let execution_status = match script.execute(&input, None) {
        Err(_) => {
            _ = std::io::copy(&mut std::io::stdin(), &mut std::io::stdout());
            eprintln!("Failed to execute script: {}", script_name);
            std::process::exit(1)
        },
        Ok(status) => status,
    };

    // read results
    // try to open error output file if specified
    let error_file = match args.error_file {
        None => None,
        Some(path) => {
            match open_output_file(path.clone()) {
                Err(msg) => {
                    eprintln!("ERROR: Failed to open --error-file {}\n\t{}", path, msg);
                    None
                },
                Ok(file) => Some(file),
            }
        }
    };
    // write error to file if possible, otherwise to stderr
    if let Some(error) = execution_status.error() {
        match error_file {
            Some(mut file) => _ = file.write_all(error.as_bytes()),
            None => eprintln!("{}", error),
        }
    }
    // try to open the info output file if specified
    let info_file = match args.info_file {
        None => None,
        Some(path) => {
            match open_output_file(path.clone()) {
                Err(msg) => {
                    eprintln!("ERROR: Failed to open --info-file {}\n\t{}", path, msg);
                    None
                },
                Ok(file) => Some(file),
            }
        }
    };
    // write info to file if possible, and to stdout per the -i flag
    if let Some(info) = execution_status.info() {
        match info_file {
            Some(mut file) => _ = file.write_all(info.as_bytes()),
            None => if args.print_info {
                println!("{}", info)
            },
        }
    }
    // if the -i flag wasn't specified, print the transformed text
    if !args.print_info {
        let replacement = execution_status.into_replacement();
        let output = match replacement {
            // Full is what I'd expect
            TextReplacement::Full(str) => str,
            // None would mean the script did not modify the text
            TextReplacement::None => input,
            // I'm not sure about these
            TextReplacement::Selection(str) => {
                eprintln!("Warning!! ExecutionStatus.into_replacement returned Selection, when Full was expected");
                str
            },
            TextReplacement::Insert(str_vec) => {
                eprintln!("Warning!! ExecutionStatus.into_replacement returned Selection, when Full was expected");
                str_vec.join("\n")
            },
        };
        print!("{}", output);
    }
    std::process::exit(0);
}
