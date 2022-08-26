# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/kai/.cache/dein/repos/github.com/junegunn/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/kai/.cache/dein/repos/github.com/junegunn/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/kai/.cache/dein/repos/github.com/junegunn/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/kai/.cache/dein/repos/github.com/junegunn/fzf/shell/key-bindings.zsh"
