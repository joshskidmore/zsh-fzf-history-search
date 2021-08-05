fzf_history_seach() {
  setopt extendedglob
  candidates=(${(f)"$(history -t '%Y-%m-%d %H:%M:%S' 0| fzf +s +m -x --tac -e -q "$BUFFER")"})
  print -v BUFFER "${candidates[@]/(#m)*/${${(As: :)MATCH}[4,-1]}}"
  zle end-of-buffer-or-history
}

autoload fzf_history_seach
zle -N fzf_history_seach

bindkey '^r' fzf_history_seach
