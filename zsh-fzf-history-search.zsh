fzf_history_seach() {
  history -t '%Y-%m-%d %H:%M:%S' 0 | grep -v 1969 | fzf +s +m -x --tac -e | awk '{print substr($0, index($0, $4))}' | tr -d "\n"
}

autoload fzf_history_seach
zle -N fzf_history_seach

bindkey '^r' fzf_history_seach