# Boop.nvim
> [!IMPORTANT]
> This is a prototype requiring a manually-built binary. A proper Neovim plugin using jobstart() is planned.

## Building
Requires Rust.

This projected has not been tested extensively on Windows or OSX, but the binary should build at least.

1. Clone this repo: `git clone https://github.com/gmvi/Boop.nvim.git`
2. Initialize the submodules: `git submodule update --init --recursive`
3. Install the boop binary: `cargo install --path . --root . --force`
4. (For Vim) Add the plugin as a package:
   `mkdir -p ~/.vim/pack/gmvi/start/ && ln -s . ~.vim/pack/gmvi/start/boop.vim`
5. (For Neovim) Add the plugin to your package manager by path. For Lazy.nvim,
   I use `{ dir = "~/src/Boop.nvim" }`
6. Put custom boop scripts in `~/.config/boop/`

## Usage

Using the default keybinds, Ctrl-B will open the Boop scratchpad from normal
mode. Pressing Ctrl-B again will populate your Vim command line with
`:BoopBuffer `, which is used to run a script on the entire scratch pad. In
visual mode, Ctrl-B will similarly populate your Vim command line with
`:'<,'>Boop `, which will run a command on the current selection only (the
`'<,'>` range specifier is ignored).

If you want custom keymaps specific to the Boop scratch pad, use an autocmd:
```
augroup boop_user_mapping
    autocmd!
    autocmd BufEnter,FileType boop call s:BoopUserMapping()
augroup END

function! s:BoopUserMapping()
    " Press <ctrl-l> to see a list of all boop scripts.
    nnoremap <buffer> <c-l> :ListBoopScripts<cr>
endfunction
```
