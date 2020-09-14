zsh=${${ZSH+${ZSH}/}:-${HOME}/.zsh_}

if [[ -f ${ZSH+${ZSH}/}zshrc ]]; then
  # shellcheck source=.zsh/zshrc
  source ${ZSH+${ZSH}/}zshrc
else
  echo "\e[01;91m No local zshrc file found."
fi
