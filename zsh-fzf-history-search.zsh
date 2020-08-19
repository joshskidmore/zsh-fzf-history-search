fzf_history_seach() {
  history -i 0 | fzf +s +m -x --tac -e | awk '{print substr($0, index($0, $4))}' | tr -d "\n"
}

autoload fzf_history_seach
zle -N fzf_history_seach

bindkey '^r' fzf_history_seach