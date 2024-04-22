# Boop.nvim
[Boop](https://github.com/IvanMathy/Boop) as a Neovim plugin. Vim will be
supported with a reduced feature set.

> [!Note]
> This project is currently tracking Boop v1.3.0 (script API version 1).
> Scripts that rely on script API version 2 are not supported at this time.

> [!Important]
> For now, prebuilt binaries are not available for newer Macbooks with the M-series chips.  
> You can still build from source, and this requires [Rust](https://www.rust-lang.org/learn/get-started).


## Normal Installation
Use your favorite plugin manager:
* Lazy.nvim / Pckr.nvim:
`{ 'gmvi/Boop.nvim' }`
* Plug: `Plug 'gmvi/Boop.nvim'`
* Pathogen:
`git clone https://github.com/gmvi/Boop.nvim.git ~/.vim/bundle/Boop.nvim`
* Vim8 native package:
`git clone https://github.com/gmvi/Boop.nvim.git ~/.vim/pack/gmvi/start/Boop.nvim`  
On Windows, replace `~/.vim` with `~/vimfiles` (for vim) or `~/AppData/Local/nvim` (for nvim).

The first time you use Boop.nvim, it will try to download a prebuilt binary for
the javascript engine. If a suitable binary isn't available then you'll have to build
from source, which takes a few minutes and requires rust (and also [msvc build
tools on Windows](https://rust-lang.github.io/rustup/installation/windows-msvc.html))

Currently, prebuilt binary download is not available for the following platforms:
* Macs with non-intel CPUs (e.g. M-series macbooks, 2020 and later)
* All 32-bit platforms
* Windows prior to Windows 10 (but it might work if you install
  [curl.exe](https://curl.se/windows/))


## Manual Install and Build from Source
Requires [Rust](https://www.rust-lang.org/learn/get-started) (and also [msvc build
tools on Windows](https://rust-lang.github.io/rustup/installation/windows-msvc.html))

1. Clone this repo and initialize submodules:  
`git clone https://github.com/gmvi/Boop.nvim.git --recurse-submodules && cd Boop.nvim`
3. Build the javascript engine binary: `cargo install --path . --root . --force`
4. (For Vim) Add the plugin to your favorite plugin manager by path, or
   move/symlink the Boop.vim/ directory into place. For vim8 native packages on
   Linux/MacOS you can do:  
   `mkdir -p ~/.vim/pack/gmvi/start/ && ln -s . ~/.vim/pack/gmvi/start/boop.vim`
5. (For Neovim) Add the plugin to your plugin manager by path.  
   For Lazy.nvim, I use `{ dir = "~/src/Boop.nvim" }`


## Usage
Put custom boop scripts in `~/.config/boop/`

Using the default keybinds, Ctrl-B will open the Boop scratchpad from normal
mode. Pressing Ctrl-B again will populate your Vim command line with
`:BoopBuffer `, which runs a boop script on the entire scratch pad (or any
file). In visual mode, Ctrl-B will similarly populate your Vim command line
with `:'<,'>Boop `, which will run a boop script on only the current selection
(once, not linewise).

You can turn off the default keybinds with
`let g:Boop_use_default_mappings = 1` (vimscript) or
`vim.g.Boop_use_default_mappings = 1` (lua)

To define custom keymaps specific to the Boop scratch pad, use a filetype
autocmd:
```vim
augroup boop_user_mapping
    autocmd!
    autocmd BufEnter,FileType boop call s:BoopUserMapping()
augroup END

function! s:BoopUserMapping()
    " Press <ctrl-l> to see a list of all boop scripts.
    nnoremap <buffer> <c-l> :ListBoopScripts<cr>
endfunction
```
To use the above in lua, you can wrap it with `vim.cmd([[` and `]])`
