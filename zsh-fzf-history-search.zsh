# do nothing if fzf is not installed
(( ! $+commands[fzf] )) && return

# Bind for fzf history search
(( ! ${+ZSH_FZF_HISTORY_SEARCH_BIND} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_BIND='^r'

# Args for fzf
(( ! ${+ZSH_FZF_HISTORY_SEARCH_FZF_ARGS} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_FZF_ARGS='+s +m -x -e --preview-window=hidden'

# Extra args for fzf
(( ! ${+ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS=''

# Cursor to end-of-line
(( ! ${+ZSH_FZF_HISTORY_SEARCH_END_OF_LINE} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_END_OF_LINE=''

# Include event numbers
(( ! ${+ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS=1

# Include full date timestamps in ISO8601 `yyyy-mm-dd hh:mm' format
(( ! ${+ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH=1

# Remove duplicate entries in history
(( ! ${+ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES=''

# Define fzf query, when $BUFFER is not empty
(( ! ${+ZSH_FZF_HISTORY_SEARCH_FZF_QUERY_PREFIX} )) &&
typeset -g ZSH_FZF_HISTORY_SEARCH_FZF_QUERY_PREFIX=''

fzf_history_search() {
  setopt extendedglob

  FC_ARGS="-l"
  CANDIDATE_LEADING_FIELDS=2

  if (( ! $ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS )); then
    FC_ARGS+=" -n"
    ((CANDIDATE_LEADING_FIELDS--))
  fi

  if (( $ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH )); then
    FC_ARGS+=" -i"
    ((CANDIDATE_LEADING_FIELDS+=2))
  fi

  history_cmd="fc ${=FC_ARGS} -1 0"

  if [ -n "${ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES}" ];then
    if (( $+commands[awk] )); then
      history_cmd="$history_cmd | awk '!seen[\$0]++'"
    else
      # In case awk is not installed fallback to uniq. It will only remove commands that are repeated consecutively.
      history_cmd="$history_cmd | uniq"
    fi
  fi

  if (( $#BUFFER )); then
    candidates=(${(f)"$(eval $history_cmd | fzf ${=ZSH_FZF_HISTORY_SEARCH_FZF_ARGS} ${=ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS} -q "${=ZSH_FZF_HISTORY_SEARCH_FZF_QUERY_PREFIX}$BUFFER")"})
  else
    candidates=(${(f)"$(eval $history_cmd | fzf ${=ZSH_FZF_HISTORY_SEARCH_FZF_ARGS} ${=ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS})"})
  fi

  local ret=$?
  if [ -n "$candidates" ]; then
    if (( ! $CANDIDATE_LEADING_FIELDS == 1 )); then
      BUFFER="${candidates[@]/(#m)[0-9 \-\:]##/$(
      printf '%s' "${${(As: :)MATCH}[${CANDIDATE_LEADING_FIELDS},-1]}" | sed 's/%/%%/g'
      )}"
    else
      BUFFER="${(j| && |)candidates}"
    fi
    zle vi-fetch-history -n $BUFFER
    if [ -n "${ZSH_FZF_HISTORY_SEARCH_END_OF_LINE}" ]; then
      zle end-of-line
    fi
  fi

  zle reset-prompt
  return $ret
}

autoload fzf_history_search
zle -N fzf_history_search

bindkey $ZSH_FZF_HISTORY_SEARCH_BIND fzf_history_search
