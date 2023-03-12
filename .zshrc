#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
# pyenvさんに~/.pyenvではなく、/usr/loca/var/pyenvを使うようにお願いする
export PYENV_ROOT=/usr/local/var/pyenv

# cargoのパスを設定
[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# 自作関数のパスを設定
export PATH="$HOME/.mycommand:$PATH"

# pyenvさんに自動補完機能を提供してもらう
eval "$(pyenv init --path)"

# pipenvのvenvをproject配下に作成するように変更
export PIPENV_VENV_IN_PROJECT=true

# load for rbenv
eval "$(rbenv init -)"

# setting for direnv
eval "$(direnv hook zsh)"

# starship
eval "$(starship init zsh)"

# settigs for homebrew
alias brew="PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin brew"

#setting for lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -al'
alias lt='ls --tree'

# setting for ripgrep
alias grep='rg'

# setting for fizzy find
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --follow --hidden --exclude .git'
export FZF_CTRL_T_COMMAND='fd --type f'
export FZF_ALT_C_COMMAND='fd --type d --follow --hidden --exclude .git'
export FZF_COMPLETION_TRIGGER="," # default: '**'
export FZF_DEFAULT_OPTS='--color=fg+:11 --height 70% --reverse --select-1 --exit-0 --multi'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#bbbbbb,bold,underline"

# docker-machine のハイパーバイザをvirtual boxに変更する
# eval "$(docker-machine env docker-host-default)"


# -----------------------------
# Lang
# -----------------------------
#export LANG=ja_JP.UTF-8
#export LESSCHARSET=utf-8

# -----------------------------
# General
# -----------------------------
# 色を使用
autoload -Uz colors ; colors

# エディタをvimに設定
export EDITOR=nvim visudo

# Spaceshipでの[I]を表示しない
SPACESHIP_VI_MODE_SHOW=false

# Ctrl+Dでログアウトしてしまうことを防ぐ
#setopt IGNOREEOF

# パスを追加したい場合
export PATH="$HOME/bin:$PATH"

# cdした際のディレクトリをディレクトリスタックへ自動追加
setopt auto_pushd

# ディレクトリスタックへの追加の際に重複させない
setopt pushd_ignore_dups

# emacsキーバインド
# bindkey -e

# viキーバインド
bindkey -v
bindkey "jj" vi-cmd-mode

# フローコントロールを無効にする
setopt no_flow_control

# ワイルドカード展開を使用する
setopt extended_glob

# cdコマンドを省略して、ディレクトリ名のみの入力で移動
setopt auto_cd

# コマンドラインがどのように展開され実行されたかを表示するようになる
#setopt xtrace

# 自動でpushdを実行
setopt auto_pushd

# pushdから重複を削除
setopt pushd_ignore_dups

# ビープ音を鳴らさないようにする
#setopt no_beep

# カッコの対応などを自動的に補完する
setopt auto_param_keys

# ディレクトリ名の入力のみで移動する
setopt auto_cd

# bgプロセスの状態変化を即時に知らせる
setopt notify

# 8bit文字を有効にする
setopt print_eight_bit

# 終了ステータスが0以外の場合にステータスを表示する
setopt print_exit_value

# ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt mark_dirs

# コマンドのスペルチェックをする
setopt correct

# コマンドライン全てのスペルチェックをする
setopt correct_all

# 上書きリダイレクトの禁止
setopt no_clobber

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

# パスの最後のスラッシュを削除しない
setopt noautoremoveslash

# 各コマンドが実行されるときにパスをハッシュに入れる
#setopt hash_cmds

# rsysncでsshを使用する
export RSYNC_RSH=ssh

# その他
umask 022
ulimit -c 0

# -----------------------------
# Completion
# -----------------------------

# zsh-completions
if [ -e /usr/local/share/zsh-competions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
  autoload -U compinit
  compinit -u
fi

# docker completons
if [ -e ~/.zsh/completions ]; then
  fpath=(~/.zsh/completions $fpath)
fi
source ~/.ghq/github.com/kwhrtsk/docker-fzf-completion/docker-fzf.zsh

# 自動補完を有効にする
autoload -Uz compinit ; compinit

# 単語の入力途中でもTab補完を有効化
setopt complete_in_word

# コマンドミスを修正
setopt correct

# 補完の選択を楽にする
zstyle ':completion:*' menu select

# 補完候補をできるだけ詰めて表示する
setopt list_packed

# 補完候補にファイルの種類も表示する
#setopt list_types

# 色の設定
export LSCOLORS=Exfxcxdxbxegedabagacad

# 補完時の色設定
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# キャッシュの利用による補完の高速化
zstyle ':completion::complete:*' use-cache true

# 補完候補に色つける
autoload -U colors ; colors ; zstyle ':completion:*' list-colors "${LS_COLORS}"
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 大文字・小文字を区別しない(大文字を入力した場合は区別する)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# manの補完をセクション番号別に表示させる
zstyle ':completion:*:manuals' separate-sections true

# --prefix=/usr などの = 以降でも補完
setopt magic_equal_subst


# -----------------------------
# Install nvm
# -----------------------------
# export NVM_DIR="$HOME/.nvm"
#  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
#  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# -----------------------------
# fzf custom functionsn
# -----------------------------
# fbr - checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# git commit をfzfで選択
alias tg='git diff $(git log --pretty=format:"%h %s" | fzf-tmux --height 100% --prompt "SELECT COMMIT>" --preview "git diff --color=always {1}\^..{1}" | awk '\''{print $1 "\^.." $1}'\'') | less -R'

# git checkout branchをfzfで選択
alias co='git checkout $(git branch -a | tr -d " " |fzf-tmux --height 100% --prompt "CHECKOUT BRANCH>" --preview "git log --color=always {}" | head -n 1 | sed -e "s/^\*\s*//g" | perl -pe "s/remotes\/origin\///g")'

#git branch --delete <branch>をfzfで選択
alias bd='git branch -d $(git branch -a | fzf --prompt "DELETE BRANCH>")'

# cdrの設定
autoload -Uz is-at-least
if is-at-least 4.3.11
then
  autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
  add-zsh-hook chpwd chpwd_recent_dirs
  zstyle ':chpwd:*'      recent-dirs-max 500
  zstyle ':chpwd:*'      recent-dirs-default yes
  zstyle ':completion:*' recent-dirs-insert both
fi

# fzf-cdr
alias cdd='fzf-cdr'
function fzf-cdr() {
    target_dir=`cdr -l | sed 's/^[^ ][^ ]*  *//' | fzf`
    target_dir=`echo ${target_dir/\~/$HOME}`
    target_dir=`echo $target_dir | sed 's/\\\\//'`
    if [ -n "$target_dir" ]; then
        cd $target_dir
    fi
}

# frepo - search repository and change directory
alias frp='frepo'
frepo() {
  local dir
  dir=$(ghq list > /dev/null | fzf-tmux +m --height 100% --prompt "SELECT REPOSITORY>") &&
    cd $(ghq root)/$dir
}


# -----------------------------
# docker setting
# -----------------------------
#構築系
alias dcb='docker-compose build'
alias dcbnc='docker-compose build --no-cache'
alias dcconf='docker-compose config'

# 起動系
alias dcup='docker-compose up'
alias dcupd='docker-compose up -d'
alias dcupb='docker-compose up --build'
alias dcupbd='docker-compose up -d --build'
alias dcstop='docker-compose stop'
alias dcdown='docker-compose down'
alias dcrst='docker-compose restart'

#プロセス系
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dcps='docker-compose ps'
alias dcpsa='docker-compose ps -a'
alias dcrm='docker-compose rm'
alias dcb='docker-compose build'

# 削除
# 各項目の全削除
alias dcpr='docker container prune'
alias dvpr='docker volume prune'
alias dipr='docker image prune'
alias dsypr='docker system prune'

# コンテナに対して操作
alias dcrun='docker-compose run'
alias dcrunrm='docker-compose run --rm'
alias dcexec='docker-compose exec'
# app コンテナに対して操作
alias dcrrb='docker-compose run --rm bash'
alias dcea='docker-compose exec app'
alias dceab='docker-compose exec app bash'


# -----------------------------
# zplug 
# -----------------------------
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "kutsan/zsh-system-clipboard"

if ! zplug check --verbose; then
  printf 'Install? [y/N: '
  if read -q; then
    echo; zplug install
  fi
fi
zplug load --verbose

# Created by `pipx` on 2021-11-26 12:12:45
export PATH="$PATH:/Users/kai/.local/bin"

# Created by `poetry` on 2022-01-22
