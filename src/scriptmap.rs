use eyre::{Context, Report, Result};
use notify::{RecommendedWatcher, RecursiveMode, Watcher};
use rust_embed::RustEmbed;
use std::{
    collections::{BTreeMap, HashMap},
    fs,
    path::{Path, PathBuf},
    sync::{Arc, RwLock},
    thread,
    time::Duration,
};

use crate::script::Script;
use crate::util::get_script_dirs;

pub struct ScriptMap(pub BTreeMap<String, Script>);

#[derive(RustEmbed)]
#[folder = "submodules/Boop/Boop/Boop/scripts/"]
pub(crate) struct Scripts;

impl ScriptMap {
    pub fn new() -> Self {
        let mut scripts = ScriptMap(BTreeMap::new());

        scripts.load_internal();

        let mut script_dirs = get_script_dirs();
        // get_script_dirs returns paths in order of precendence, so load them
        // in reverse order to override scripts properly
        script_dirs.reverse();
        for script_dir in script_dirs {
            scripts.load_path(&script_dir).ok();
        }

        scripts
    }

    // load scripts included in the binary
    fn load_internal(&mut self) {
        for file in Scripts::iter() {
            // scripts are internal, so we can unwrap "safely"
            let script_source = String::from_utf8(Scripts::get(&file).unwrap().to_vec()).unwrap();
            if let Ok(script) = Script::from_source(script_source, PathBuf::new()) {
                self.0.insert(script.metadata.name.clone(), script);
            }
        }

        info!("loaded {} internal scripts", Scripts::iter().count());
    }

    // load scripts from a path
    fn load_path(&mut self, dir: &Path) -> Result<()> {
        let paths = fs::read_dir(dir)
            .wrap_err_with(|| format!("Failed to read scripts directory: {}", dir.display()))?;

        let scripts: HashMap<String, Script> = paths
            .filter_map(Result::ok)
            .map(|f| f.path())
            .filter(|path| path.is_file())
            .map(Script::from_file)
            .filter_map(Result::ok)
            .map(|script| (script.metadata.name.clone(), script))
            .collect();

        info!("loaded {} scripts from {}", scripts.len(), dir.display());

        self.0.extend(scripts);

        Ok(())
    }

    pub(crate) fn watch(scripts: Arc<RwLock<Self>>) {
        trace!("watch_scripts_folder");

        // watch for changes to script folder
        let watcher: notify::Result<RecommendedWatcher> = Watcher::new_immediate(move |res| {
            debug!("res: {:?}", res);
            match res {
                Ok(event) => {
                    let event: notify::Event = event;

                    for file in event.paths {
                        debug!("file: {}", file.display());

                        if file.extension().filter(|&s| s == "js").is_none() {
                            break;
                        }

                        info!("{} changed, reloading", file.display());

                        let mut scripts = scripts.write().expect("script lock is poisoned");

                        // remove script
                        // TODO: replace with drain_filter when stabalized
                        let mut matched = None;
                        for (name, script) in scripts.0.iter() {
                            if script.path == file {
                                matched = Some(name.clone());
                            }
                        }
                        if let Some(name) = matched {
                            scripts.0.remove(&name);
                        }
                        // scripts.0.drain_filter(|_, script| script.path == file);

                        if !file.exists() {
                            // file was deleted
                            break;
                        }

                        match Script::from_file(file.clone()) {
                            Ok(script) => {
                                // file added or changed
                                scripts.0.insert(script.metadata.name.clone(), script);
                            }
                            Err(e) => {
                                warn!("error parsing {}: {}", file.display(), e);
                            }
                        }
                    }
                }
                Err(e) => error!("watch error: {:?}", e),
            }
        });

        // configure and start watcher
        match watcher {
            Ok(mut watcher) => {
                let script_dir = &get_script_dirs()[0];

                info!("watching {}", script_dir.display());

                if let Err(watch_error) = watcher.watch(script_dir, RecursiveMode::Recursive) {
                    error!("watch start error: {}", watch_error);
                    return;
                }

                // keep the thread alive
                loop {
                    trace!("watching!");
                    thread::sleep(Duration::from_millis(1000));
                }
            }
            Err(watcher_error) => {
                error!("couldn't create watcher: {}", watcher_error);
            }
        }
    }
}
