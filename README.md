# Boop.nvim
> [!IMPORTANT]
> This is a prototype requiring a manually-built binary. A proper Neovim plugin using jobstart() is planned.

## Building
Requires Rust.

This projected has not been tested extensively on Windows or OSX, but the binary should build at least.

1. Clone this repo: `git clone https://github.com/gmvi/Boop.nvim.git`
2. Initialize the submodules: `git submodule update --init --recursive`
3. Install the boop binary: `cargo install --path . --root . --force`
4. (For Vim) Add the plugin as a package: `mkdir -p ~/.vim/pack/gmvi/start/ && ln -s . ~.vim/pack/gmvi/start/boop.vim`
5. (For Neovim) Add the plugin to your package manager by path. For Lazy.nvim I use `{ dir = "~/src/Boop.nvim" }`
6. Put custom boop scripts in `~/.config/boop/`
7. If you want to remap keys within the Boop scratch pad, use the following:
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

## Usage
Coming Soon
