if exists('g:loaded_oldfiles_startup_screen') | finish | endif

if !has('nvim')
    echohl Error
    echom "Sorry this plugin only works with versions of neovim that support lua"
    echohl clear
    finish
endif

let g:loaded_oldfiles_startup_screen = 1

autocmd VimEnter * nested lua require('OldfilesStartupScreen').display()
autocmd FileType OldfilesStartupScreen set laststatus=0 | autocmd WinLeave,BufLeave <buffer> set laststatus=2

augroup OldfilesStartupScreen
  autocmd!
  autocmd BufNew * lua require('OldfilesStartupScreen').delete_buf()
augroup END

