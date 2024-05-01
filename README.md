# Boop.nvim
[Boop.app](https://github.com/IvanMathy/Boop) as a Neovim plugin.
Vim will be supported with a reduced feature set.

Do you find yourself pasting into strange websites to convert “smart” quotes or apply SpOngE caSe?
Don't risk accidentally leaking company-confidential data, use Boop to keep your data local.

> [!Note]
> This project is currently tracking Boop.app v1.3.0 (script API version 1).  
> Scripts that rely on API version 2 (all the parser libraries) are not yet supported.

> [!Important]
> This project does not support 32-bit platforms because [Deno](https://deno.com/)
> does not support them.  
> Additionally, Android is not supported at this time.


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
the javascript engine. If a suitable binary isn't available then you'll need to
build from source, which may be quite slow depending on your machine.

Currently, prebuilt binary download is not available for the following platforms:
* Windows prior to Windows 10 (but it might work if you install
  [curl.exe](https://curl.se/windows/))
* Android (i.e. Termux), but cross-compilation may be possible (see **Build from Source** below).


## Usage
Put custom boop scripts in `~/.config/boop/`

Boop.nvim provides the :Boop and :BoopPad commands to run scripts and open the Boop pad
```vim
" Applies a script to either the current file (default), or specific lines in a range.
" Currently, calling with no <script name> will press tab for you to trigger autocomplete.
" A popup selector is in the works with icons and descriptions like the original Boop app.
:Boop <script name> " no range provided
:.Boop <script name> " range is . (current line)
" If you want :Boop to apply to just the current line by default, set g:Boop_default_action
let g:Boop_default_action = '.'
" Use :%Boop to boop the entire file regardless of the default action setting
:%Boop <script name> 
" From visual mode, calling :Boop will apply a script only to the visual selection.
" Vim will insert :'<,'> for you. This is the range of lines covered by the selection.
" Boop.nvim will use your actual visual selection, rather than taking this line range literally.
:'<,'>Boop <script name>
"TODO: fix blockwise visual :Boop

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
"TODO: implement :browse BoopPad and :BoopPad {path}

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

Using the default keybinds, Ctrl-B will open the Boop pad from normal mode.
Press Ctrl-B within this scratch pad to run a Boop script on the entire text.
In visual mode, press Ctrl-B in any file to run a Boop script on that selection
char-wise or line-wise. Block-mode visual booping is not supported at this time.

You can prevent the default keybinds with
`let g:Boop_use_default_mappings = 0` (vimscript) or
`vim.g.Boop_use_default_mappings = 0` (lua).

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
