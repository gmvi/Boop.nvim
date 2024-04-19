// don't actually do anything anymore, but keep this here in case we want to have clap build completions for non-bash shells
//use io::Write;
//use std::{env, fs, io, path::Path, process::Command};
//use clap_complete::{generate_to, shells};
//use clap::CommandFactory;
//
//include!("src/cli.rs");
//
//fn build_boop_cli_resources() {
//    let mut app = Cli::command();
//    app.set_bin_name("boop");
//
//    let out_dir = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("completions");
//    
//    std::fs::create_dir_all(&out_dir);
//    //    format!( "Failed to create scripts directory in config: {}", out_dir.display())
//    
//    // no bash here because this version of clap doesn't support dynamic completions
//    // using the --list-scripts flag, so there's a custom one instead
//    generate_to(shells::Fish, &mut app, "boop", out_dir.clone());
//    generate_to(shells::Zsh, &mut app, "boop", out_dir.clone());
//    generate_to(shells::PowerShell, &mut app, "boop", out_dir.clone());
//    generate_to(shells::Elvish, &mut app, "boop", out_dir.clone());
//}

fn main() {
    //build_boop_cli_resources();
}