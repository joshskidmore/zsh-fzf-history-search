# zsh/fzf History Search
![zsh-fzf-history-search plugin screenshot](https://josh.sh/5UPr.png)

A simple zsh plugin to replace `Ctrl-r` with an fzf-driven, searchable list of history.

**Pull requests always appreciated!**

## Requirements
* [fzf](https://github.com/junegunn/fzf)

## Installation with zinit

Add this to `~/.zshrc`:

```sh
# zsh-fzf-history-search
zinit ice lucid wait'0'
zinit light joshskidmore/zsh-fzf-history-search
```

## TODO
* use fzf's keybindings for additional functionality (remove specific history item, clear history, etc) while keeping plugin's simplicity in mind ([issue](https://github.com/joshskidmore/zsh-fzf-history-search/issues/10))
* better documentation ([issue](https://github.com/joshskidmore/zsh-fzf-history-search/issues/11))
