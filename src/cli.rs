use clap::Parser;

#[derive(Parser, Debug)]
#[command(version, name = "boop", bin_name = "boop")]
#[command(override_usage = "
    cat file.txt | boop <SCRIPT_NAME> | sponge file.txt
    cat file.txt | boop -i \"Count Words\"
    echo \"Lorem Ipsum\" | boop Rot13")]
// Using trailing_var_arg here so the user can forget to quote the script name.
// Otherwise, Clap would abort due to too many args. This requires the last
// arg to be multiple_values, so tell Clap to require at least one arg.
#[command(trailing_var_arg=true, arg_required_else_help=true)]
#[group(id = "op_mode", required = true)]
pub(crate) struct Cli {
    #[arg(long, short='l', group="op_mode")]
    pub list_scripts: bool,

    #[arg(long, hide=true, group="op_mode")]
    pub rpc: bool,

    #[arg(long, short='i')]
    pub print_info: bool,

    #[arg(long)]
    pub info_file: Option<String>,

    #[arg(long)]
    pub error_file: Option<String>,

    #[arg(group="op_mode")]
    pub script_name: Vec<String>,
}