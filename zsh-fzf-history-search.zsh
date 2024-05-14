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

forgetline() {
    # Extract the command to delete, assuming it's the entire command string after the initial metadata
    # local command_to_delete=$(echo "$1" | sed -E 's/^[0-9]+[[:space:]]+[0-9-]+[[:space:]]+[0-9:]+[[:space:]]+//')
    local command_to_delete=$(echo "$1" | awk '{$1=$2=$3=""; sub(/^[ \t]+/, ""); print}')

    # Properly escape the command to delete for use in sed
    local escaped_command=$(printf '%s\n' "$command_to_delete" | sed -e 's/[\/&]/\\&/g')

    # Set the location of the history file
    local histfile="${HISTFILE:-$HOME/.zsh_history}"

    # Make a backup of the current history file
    #cp "$histfile" "$histfile.bak"

    # Use sed to remove lines containing the escaped command
    sed -i "/$escaped_command$/d" "$histfile"

    # Check if sed succeeded
    if [ $? -eq 0 ]; then
        true
        #echo "\nDeleted entries matching: '$command_to_delete' from history."
    else
        echo "Failed to delete entries. Please check the command and history file."
    fi

    #refresh the session histories
    if ! screen >/dev/null; then
        screen -ls | grep -oP '\d+\.\S+' | while read session_id; do
            screen -S "$session_id" -X stuff $'\nfc -R\n'
        done
    if ! tmux >/dev/null; then
        tmux list-sessions -F '#{session_id}' | while read session_id; do
            tmux send-keys -t "$session_id" Enter 'fc -R' Enter
        done


    #Other ways to reload your session history
    #exec zsh
    #omz reload
    return
}

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

  if [ -n "${ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES}" ]; then
    if (( $+commands[awk] )); then
      history_cmd="$history_cmd | awk '!seen[\$0]++'"
    else
      # In case awk is not installed fallback to uniq. It will only remove commands that are repeated consecutively.
      history_cmd="$history_cmd | uniq"
    fi
  fi

  local fzf_bind="delete:execute(source $(dirname ${(%):-%N})/zsh-fzf-history-search/zsh-fzf-history-search.zsh; forgetline {1..-1})+abort"
  local fzf_extra_args="--bind '$fzf_bind' $ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS"
  # Check if there is an initial query set in BUFFER
  if (( $#BUFFER )); then
    local fzf_command="eval $history_cmd | fzf ${=ZSH_FZF_HISTORY_SEARCH_FZF_ARGS} $fzf_extra_args -q '${=ZSH_FZF_HISTORY_SEARCH_FZF_QUERY_PREFIX}$BUFFER'"
  else
    local fzf_command="eval $history_cmd | fzf ${=ZSH_FZF_HISTORY_SEARCH_FZF_ARGS} $fzf_extra_args"
  fi
  # Execute fzf command and capture candidates
  candidates=("${(@f)$(eval "$fzf_command")}")
  local ret=$?
  if [ -n "$candidates" ]; then
    if (( $CANDIDATE_LEADING_FIELDS != 1 )); then
      BUFFER="${candidates[@]/(#m)[0-9 \-\:]##/${${(As: :)MATCH}[${CANDIDATE_LEADING_FIELDS},-1]}}"
    else
      BUFFER="${(j| && |)candidates}"
    fi
    BUFFER=$(printf "${BUFFER[@]//\\\\n/\\\\\\n}")
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
zle -N forgetline
bindkey $ZSH_FZF_HISTORY_SEARCH_BIND fzf_history_search
bindkey '[^F' forgetline
