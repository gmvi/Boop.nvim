use clap::{
    Parser,
    ArgGroup,
};

#[derive(Parser, Debug)]
#[clap(override_usage = "echo blah blah | boop <SCRIPT_NAME>")]
// Using trailing_var_arg here so the user can forget to quote the script name.
// Otherwise, Clap would abort due to too many args. This requires the last
// arg to be multiple_values, so tell Clap to require at least one arg.
#[clap(trailing_var_arg=true, arg_required_else_help=true)]
#[clap(group(ArgGroup::new("op_mode").required(true).args(&[
    "list_scripts", "script_name"
])))]
pub(crate) struct Cli {
    #[clap(long, short='l')]
    pub list_scripts: bool,

    #[clap(multiple_values=true)]
    pub script_name: Vec<String>,
}