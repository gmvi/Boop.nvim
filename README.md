# Boop.nvim
[Boop](https://github.com/IvanMathy/Boop) as a Neovim plugin.
Vim will be supported with a reduced feature set.

Do you find yourself pasting text into websites to do things like convert smart quotes or apply SpOngE caSe?
Don't risk accidentally pasting company-confidential data into strange websites, use Boop to keep your data local.

> [!Note]
> This project is currently tracking Boop.app v1.3.0 (script API version 1).
> Scripts that rely on script API version 2 are not supported yet.

> [!Important]
> This project does not support 32-bit platforms because [Deno](https://deno.com/)
> does not support them.  
> Additionally, Android (Termux) is not supported at this time.


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
the javascript engine. If a suitable binary isn't available then you'll have to
build from source, which may be quite slow depending on your machine.

Currently, prebuilt binary download is not available for the following platforms:
* Windows prior to Windows 10 (but it might work if you install
  [curl.exe](https://curl.se/windows/))
* Android (e.g. Termux), but cross-compilation may be possible (see next section).


## Usage
Put custom boop scripts in `~/.config/boop/`

Boop.nvim provides the following Ex commands to run scripts and open the Boop pad
```vim
" Applies a script to either the current file (default), or specific lines if a <range> is provided.
" In Neovim, calling with no <script name> opens a popup list of scripts with descriptions.
:Boop <script name>
:.Boop <script name> " Boops just the current line
" If you want :Boop to apply to just the current line by default, set g:Boop_default_action
let g:Boop_default_action = '.'
" Use :%Boop to boop the entire file regardless of g:Boop_default_action
:%Boop <script name> 
" From visual mode, calling :Boop will apply a script only to the visual selection
" Vim will insert :'<,'> for you; this is the range of lines covered by the selection
" The :Boop command will use your actual visual selection, rather than linewise
:'<,'>Boop <script name>
"TODO: make blockwise visual selection work

" Opens the Boop scratch-pad, which provides an experience similar to the original Boop app.
:BoopPad
" From visual mode, this will open the Boop pad with the most recent visual selection
:'<,'>BoopPad
" In neovim, it's a floating window. In vim, it's a scratch buffer in a split.
" (see `:help scratch` or https://vimhelp.org/windows.txt.html#scratch-buffer )
" :BoopPad forwards modifiers to :new, and calling it twice won't open multiple splits.
" You can also use these modifiers in Neovim to open the Boop pad in a split or a tab.
:horiz BoopPad " default for Vim
:vert BoopPad
:tab BoopPad
"TODO: make these work for neovim after already opening the floating window
" TODO: implement :browse BoopPad and :BoopPad {path}

" After running a script you can replace your old selection with the result like this:
" :%y or ggyG to yank the entire Boop pad
" :q or ZQ or <c-w>c to close the Boop pad
" gvp to paste over your old selection (mnemonic: "go visual; paste", see :help gv)

" Other ways to use g:Boop_default_action to change the default behavior of the :Boop command:
" 'pad' - calling just :Boop from normal mode, with no range or script, acts like :BoopPad
:let g:Boop_default_action = 'pad' 
" 'pad:visual' - like 'pad', but calling just :Boop from visual mode also acts like :BoopPad
:let g:Boop_default_action = 'pad:visual'
```

Using the default keybinds, Ctrl-B will open the Boop scratchpad from normal mode.
Pressing Ctrl-B within this scratch runs a boop script on the entire scratch pad (or any
file). In visual mode, Ctrl-B will similarly populate your Vim command line
with `:'<,'>Boop `, which will run a boop script on only the current selection
(once, not linewise).

You can turn off the default keybinds with
`let g:Boop_use_default_mappings = 1` (vimscript) or
`vim.g.Boop_use_default_mappings = 1` (lua)

To define custom keymaps only within the Boop pad, use a filetype autocmd:
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


## Manual Install and Build from Source
Requires [Rust](https://www.rust-lang.org/learn/get-started). On Windows, requires
[msvc build tools](https://rust-lang.github.io/rustup/installation/windows-msvc.html).

Android and all 32-bit platforms are not supported. Though you might be able to
[cross-compile for 64-bit Android](https://doc.rust-lang.org/stable/rustc/platform-support/android.html)
using this [3rd-party build of rusty_v8](https://github.com/fm-elpac/v8-src/releases/tag/rusty_v8-0.83.2).

1. Clone this repo and initialize submodules:  
`git clone https://github.com/gmvi/Boop.nvim.git --recurse-submodules && cd Boop.nvim`
3. Build the javascript engine binary: `cargo install --path . --root . --force`
4. (For Vim) Add the plugin to your favorite plugin manager by path, or
   move/symlink the Boop.nvim/ directory into place. For vim native packages on
   Linux/MacOS you can do:  
   `mkdir -p ~/.vim/pack/gmvi/start/ && ln -s . ~/.vim/pack/gmvi/start/Boop.nvim`
5. (For Neovim) Add the plugin to your plugin manager by path.  
   For Lazy.nvim, I use `{ dir = "~/src/Boop.nvim" }`
