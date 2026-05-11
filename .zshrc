# Keep path-like arrays unique
typeset -U path cdpath fpath manpath

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git gh docker docker-compose history gradle mvn sudo vi-mode)
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# History (must come after oh-my-zsh, which sets its own defaults)
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

# fzf key bindings and completion
if command -v fzf >/dev/null 2>&1 && [[ $options[zle] = on ]]; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    for f in \
      /usr/share/doc/fzf/examples/key-bindings.zsh \
      /usr/share/doc/fzf/examples/completion.zsh \
      /usr/share/fzf/key-bindings.zsh \
      /usr/share/fzf/completion.zsh; do
      [[ -r $f ]] && source "$f"
    done
  fi
fi

# Shell options
setopt HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
setopt NO_APPEND_HISTORY NO_EXTENDED_HISTORY NO_HIST_EXPIRE_DUPS_FIRST
setopt NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS NO_HIST_SAVE_NO_DUPS

# zsh-syntax-highlighting (must be sourced before zsh-autosuggestions)
for f in \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -r $f ]] && source "$f" && break
done
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

# zsh-autosuggestions (must be sourced last so its widgets wrap everything else)
for f in \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  [[ -r $f ]] && source "$f" && break
done
ZSH_AUTOSUGGEST_STRATEGY=(history)
