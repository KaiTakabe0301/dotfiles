set number             "行番号を表示
set autoindent         "改行時に自動でインデントする
set tabstop=2          "タブを何文字の空白に変換するか
set shiftwidth=2       "自動インデント時に入力する空白の数
set expandtab          "タブ入力を空白に変換
set splitright         "画面を縦分割する際に右に開く
set clipboard=unnamed  "yank した文字列をクリップボードにコピー
set hls                "検索した文字をハイライトする
syntax on

" ------------------------------------------------------------
"  key bind
" ------------------------------------------------------------
"  leaderを変更
let mapleader = "\<Space>"


" Normal Mode
cnoremap init :<C-u>edit $MYVIMRC<CR>  " init.vim呼び出し
nnoremap <leader>s :source $MYVIMRC<CR>  " init.vim読み込み
nnoremap <leader>w :<C-u>w<CR>           " ファイル保存
" 表示行単位で上下移動するように
nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up>   gk
" 逆に普通の行単位で移動したい時のために逆の map も設定しておく
nnoremap gj j
nnoremap gk k
" 行頭行末の移動にleaderを使用
nnoremap <leader>a ^
nnoremap <leader>e $
" 行頭行末の移動にleaderを使用
nnoremap ; :
nnoremap : ;

" バッファの切り替え
nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprev<CR>
nnoremap <leader>x :bd<CR>

" 一文字削除の時は、ブラックホールレジスタに格納
nnoremap x "_x
nnoremap X "_X

" 行削除の時は、ブラックホールレジスタに格納 
nnoremap dd "_dd

" Insert Mode
inoremap <silent> jj <ESC>
" Insert mode movekey bind
inoremap <C-d> <BS>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-j> <Down>
inoremap <C-k> <Up>

" Command Mode
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
" <C-a> はtmuxのprefixと被っているので考える必要あり
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-d> <Del>

" ------------------------------------------------------------
" Start dein.vim Script 
" ------------------------------------------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" reset augroup
augroup MyAutoCmd
 autocmd!
augroup END

" install dir {{{
" dein自体の自動インストール
let s:cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
let s:dein_dir = s:cache_home . '/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim') . shellescape(s:dein_repo_dir)
endif
" }}}

" Required:
let &runtimepath = s:dein_repo_dir . ',' . &runtimepath
let s:toml_file = fnamemodify(expand('<sfile>'),':h') . '/dein.toml'

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  call dein#load_toml(s:toml_file)
  call dein#end()
  call dein#save_state()
endif

" 不足プラグインの自動インストール
if has('vim_starting') && dein#check_install()
  call dein#install()
endif

" plugin remove check {{{
let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
  call map(s:removed_plugins, "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endif
" }}}
" ------------------------------------------------------------
" End dein.vim Script 
" ------------------------------------------------------------


filetype plugin indent on
syntax on


" ------------------------------------------------------------
" Start dense-analysis/ale setting
" ------------------------------------------------------------
" 保存時のみ実行する
let g:ale_lint_on_text_changed = 0
" 表示に関する設定
let g:ale_sign_error = ''
let g:ale_sign_warning = ''
let g:airline#extensions#ale#open_lnum_symbol = '('
let g:airline#extensions#ale#close_lnum_symbol = ')'
let g:ale_echo_msg_format = '[%linter%]%code: %%s'
highlight link ALEErrorSign Tag
highlight link ALEWarningSign StorageClass
" Ctrl + kで次の指摘へ、Ctrl + jで前の指摘へ移動
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
" ------------------------------------------------------------
" End dense-analysis/ale setting
" ------------------------------------------------------------


" ------------------------------------------------------------
" Start vim-airline-theme
" https://qiita.com/reireias/items/beaa3bb0e299ae934217
" ------------------------------------------------------------
let g:airline_theme='dark'
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#wordcount#enabled = 0
let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'y', 'z']]
let g:airline_section_c = '%t'
let g:airline_section_x = '%{&filetype}'
let g:airline_section_z = '%3l:%2v %{airline#extensions#ale#get_warning()} %{airline#extensions#ale#get_error()}'
let g:airline#extensions#ale#error_symbol = ' '
let g:airline#extensions#ale#warning_symbol = ' '
let g:airline#extensions#default#section_truncate_width = {}
let g:airline#extensions#whitespace#enabled = 1
" ------------------------------------------------------------
" End vim-airline-theme
" ------------------------------------------------------------


" ------------------------------------------------------------
" Start fzf-preview.vim setting
" ------------------------------------------------------------
" nmap <Leader>f [fzf-p]
" xmap <Leader>f [fzf-p]

" nnoremap <silent> [fzf-p]p     :<C-u>CocCommand fzf-preview.FromResources project_mru git<CR>
" nnoremap <silent> [fzf-p]gs    :<C-u>CocCommand fzf-preview.GitStatus<CR>
" nnoremap <silent> [fzf-p]ga    :<C-u>CocCommand fzf-preview.GitActions<CR>
" nnoremap <silent> [fzf-p]b     :<C-u>CocCommand fzf-preview.Buffers<CR>
" nnoremap <silent> [fzf-p]B     :<C-u>CocCommand fzf-preview.AllBuffers<CR>
" nnoremap <silent> [fzf-p]o     :<C-u>CocCommand fzf-preview.FromResources buffer project_mru<CR>
" nnoremap <silent> [fzf-p]<C-o> :<C-u>CocCommand fzf-preview.Jumps<CR>
" nnoremap <silent> [fzf-p]g;    :<C-u>CocCommand fzf-preview.Changes<CR>
" nnoremap <silent> [fzf-p]/     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
" nnoremap <silent> [fzf-p]*     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
" nnoremap          [fzf-p]gr    :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
" xnoremap          [fzf-p]gr    "sy:CocCommand   fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
" nnoremap <silent> [fzf-p]t     :<C-u>CocCommand fzf-preview.BufferTags<CR>
" nnoremap <silent> [fzf-p]q     :<C-u>CocCommand fzf-preview.QuickFix<CR>
" nnoremap <silent> [fzf-p]l     :<C-u>CocCommand fzf-preview.LocationList<CR>
" nnoremap <silent> [fzf-p]y     :<C-u>CocCommand fzf-preview.Yankround<CR>
" ------------------------------------------------------------
" End fzf-preview.vim setting
" ------------------------------------------------------------

" ------------------------------------------------------------
" Start yankroundn.vim setting
" ------------------------------------------------------------
nmap <Leader>y [yankround]
xmap <Leader>y [yankround]
nmap p <Plug>(yankround-p)
xmap p <Plug>(yankround-p)
nmap P <Plug>(yankround-P)
nmap gp <Plug>(yankround-gp)
xmap gp <Plug>(yankround-gp)
nmap gP <Plug>(yankround-gP)
nmap <silent> [yankround]p <Plug>(yankround-prev)
nmap <silent> [yankround]n <Plug>(yankround-next)
" ------------------------------------------------------------
" End yankroundn.vim setting
" ------------------------------------------------------------

