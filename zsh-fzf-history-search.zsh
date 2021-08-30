fzf_history_seach() {
  setopt extendedglob
  candidates=(${(f)"$(fc -li -1 0 | fzf +s +m -x -e -q "$BUFFER")"})
  BUFFER="${candidates[@]/(#m)*/${${(As: :)MATCH}[4,-1]}}"
  BUFFER="${BUFFER[@]/(#b)(?)\\n/$match[1]
}"
  zle end-of-buffer-or-history
}

autoload fzf_history_seach
zle -N fzf_history_seach

bindkey '^r' fzf_history_seach
