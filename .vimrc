let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
let Tlist_Ctags_Cmd='/usr/local/bin/ctags'
map T :TaskList<CR>
map P :TlistToggle<CR>
set expandtab
set textwidth=79
set tabstop=8
set softtabstop=4
set shiftwidth=4
set autoindent
set noai
highlight RedundantWhitespace ctermbg=red guibg=red
map <F12> :set number!<CR>
:syntax on
