# Boop.nvim
[Boop](https://github.com/IvanMathy/Boop) as a Neovim plugin. Vim is also
supported, with a reduced feature set.
> [!Note]
> This project is currently tracking Boop v1.3.0 (script API version 1)
> Scripts that rely on script API version 2 are not supported at this time.


## Normal Installation
Use your favorite plugin manager:
* Lazy:
`{ 'gmvi/Boop.nvim' }`
* Plug: `Plug 'gmvi/Boop.nvim', { 'do': 'git submodule update --init --recursive' }`
* Pathogen:
`git clone https://github.com/gmvi/Boop.nvim.git --recurse-submodules ~/.vim/bundle/Boop.nvim`
* Vim8 native package:
`git clone https://github.com/gmvi/Boop.nvim.git --recurse-submodules ~/.vim/pack/gmvi/start/Boop.nvim`
On Windows, replace `~/.vim` with `~/vimfiles` (for vim) or `~/AppData/Local/nvim` (for nvim).

The first time you use Boop.nvim, it will try to download a prebuilt binary for
the core engine. If a suitable binary isn't available then you'll have to build
from source, which requires rust and may take a few minutes.

Currently, prebuilt binary download is not available for the following platforms:
* Macs with non-intel CPUs (e.g. M-series macbooks, 2020 and later)
* All 32-bit platforms
* Windows prior to Windows 10 (might work if you install
  [curl.exe](https://curl.se/windows/); untested)


## Manual Install and Build from Source
Requires rust.

1. Clone this repo and initialize submodules:  
`git clone https://github.com/gmvi/Boop.nvim.git --recurse-submodules && cd Boop.nvim`
3. Build the boop engine binary: `cargo install --path . --root . --force`
4. (For Vim) Add the plugin to your favorite plugin manager by path, or
   move/symlink the Boop.vim/ directory into place. For vim8 native packages on
   Linux/MacOS you can do:  
   `mkdir -p ~/.vim/pack/gmvi/start/ && ln -s . ~.vim/pack/gmvi/start/boop.vim`
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
