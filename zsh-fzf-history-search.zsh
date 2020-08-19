fzf_history_seach() {
  local _history=$(history -i 0)

  [[ -z "$_history" ]] && exit

  echo -e "$_history"| fzf +s +m -x --tac -e | awk '{print substr($0, index($0, $4))}' | tr -d "\n"
}

autoload fzf_history_seach
zle -N fzf_history_seach

bindkey '^r' fzf_history_seach