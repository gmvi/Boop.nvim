use std::{
    env::consts::OS,
    path::PathBuf,
    string::FromUtf8Error,
};

use eyre::Result;

pub trait StringExt {
    fn remove_null_bytes(self) -> Result<String, FromUtf8Error>;
}

impl StringExt for String {
    fn remove_null_bytes(self) -> Result<String, FromUtf8Error> {
        String::from_utf8(
            self.into_bytes()
                .into_iter()
                .filter(|b| *b != 0)
                .collect::<Vec<u8>>(),
        )
    }
}

// returns script dirs in order of precedence
pub(crate) fn get_script_dirs() -> Vec<PathBuf> {
    let mut dirs = vec![];
    if let Some(sys_dirs) = directories::BaseDirs::new() {
        let mut base_dirs = vec![];
        base_dirs.push(sys_dirs.config_dir());
        // Windows and Linux have additional directories which seem relevant
        if OS == "windows" {
            base_dirs.insert(0, sys_dirs.config_local_dir());
        } else if OS == "linux" {
            base_dirs.push(sys_dirs.data_dir());
        }
        // Only boop-gtk sets a default user scripts directory
        // Support a ~/.config/boop directory (or equivalent) on all platforms
        for base in base_dirs {
            dirs.push(PathBuf::from(base.join("boop")));
            if OS == "linux" {
                dirs.push(PathBuf::from(base.join("boop-gtk/scripts")));
            }
        }
    }
    dirs
}