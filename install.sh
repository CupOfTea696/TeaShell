#!/bin/sh

DIR=$(dirname "$0")

if ! [[ $DIR = '.' ]]; then
    DIR="$(pwd)/$DIR"
else
    DIR="$(pwd)"
fi

clear

export LC_CTYPE="utf-8"

NON_INTERACTIVE=false

for i in "$@"
do
case $i in
    -n|--no-interaction)
    NON_INTERACTIVE=true
    shift # past argument=value
    ;;
    *)
    # unknown option
    ;;
esac
done

if [[ "$NON_INTERACTIVE" = true ]]; then
    echo 'Running in non-interactive mode... All packages will be installed.'
fi

mkdir ~/.tshell_tmp
cd ~/.tshell_tmp || (>&2 echo "Failed to create .tmp directory"; exit)

# Install hr
curl https://raw.githubusercontent.com/LuRsT/hr/master/hr > /usr/local/bin/hr
chmod +x /usr/local/bin/hr

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install completions, git, mysql, wget
brew install bash-completion git mysql wget zsh

# hub
export HUB_INSTALLED=false
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Do you want to install hub? [y/n] " -n 1 -r
    echo
fi
if [[ $REPLY =~ ^[Yy]$ || "$NON_INTERACTIVE" = true ]]; then
    HUB_INSTALLED=true
    brew install hub
fi

# PHP
export PHP_INSTALLED=false
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Do you want to install PHP 7.x? [y/n] " -n 1 -r
    echo
fi
if [[ $REPLY =~ ^[Yy]$ || "$NON_INTERACTIVE" = true ]]; then
    PHP_INSTALLED=true
    brew install php@7.2
    brew install php@7.3
    brew install php
fi

## Composer
export COMPOSER_INSTALLED=false
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Do you want to install Composer? [y/n] " -n 1 -r
    echo
fi
if [[ $REPLY =~ ^[Yy]$ || "$NON_INTERACTIVE" = true ]]; then
    COMPOSER_INSTALLED=true

    ### Install composer...
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === trim(file_get_contents('https://composer.github.io/installer.sig'))) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    mv composer.phar /usr/local/bin/composer

    composer -V

    composer global require phpunit/phpunit
    composer global require laravel/installer
fi

# N & Yarn
export YARN_INSTALLED=false
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Do you want to install Yarn? [y/n] " -n 1 -r
    echo
fi
if [[ $REPLY =~ ^[Yy]$ || "$NON_INTERACTIVE" = true ]]; then
  YARN_INSTALLED=true

  ### Install yarn...
  brew install yarn
fi

export N_INSTALLED=false
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Do you want to use multiple Node versions? LTS and latest versions will be installed [y/n] " -n 1 -r
    echo
fi
if [[ $REPLY =~ ^[Yy]$ || "$NON_INTERACTIVE" = true ]]; then
  N_INSTALLED=true

  ### Install n...
  brew install n
  sudo n lts
  sudo n latest

  ### Install n-update
  if [[ "$YARN_INSTALLED" = true ]]; then
    yarn global add n-update-cli
  else
    npm -g install n-update-cli
  fi
fi

# NPM Packages
## fast, speedtest
export FAST_INSTALLED=false
export SPEED_INSTALLED=false
export FAST_SPEED_INSTALLED=false
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Do you want to install Fast and/or Speedtest? [1=Fast | 2=Speedtest | 3=Both]" -n 1 -r
    echo
fi
if [[ $REPLY =~ ^[13]$ || "$NON_INTERACTIVE" = true ]]; then
  ### Install Fast
  FAST_INSTALLED=true
  FAST_SPEED_INSTALLED=true

  if [[ "$YARN_INSTALLED" = true ]]; then
    yarn global add fast-cli
  else
    npm -g install fast-cli
  fi
fi
if [[ $REPLY =~ ^[23]$ || "$NON_INTERACTIVE" = true ]]; then
  ### Install Fast
  SPEED_INSTALLED=true
  FAST_SPEED_INSTALLED=true

  if [[ "$YARN_INSTALLED" = true ]]; then
    yarn global add speed-test
  else
    npm -g install speed-test
  fi
fi

## trash
export TRASH_INSTALLED=false
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Do you want to install Trash? [y/n] " -n 1 -r
    echo
fi
if [[ $REPLY =~ ^[Yy]$ || "$NON_INTERACTIVE" = true ]]; then
  TRASH_INSTALLED=true

  ### Install Trash...
  if [[ "$YARN_INSTALLED" = true ]]; then
    yarn global add trash-cli empty-trash-cli del-cli
  else
    npm -g install trash-cli empty-trash-cli del-cli
  fi
fi

# Fortune & Cowsay
export FORTUNE_INSTALLED=false
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Do you want to install Fortune & Cowsay? [y/n] " -n 1 -r
    echo
fi
if [[ $REPLY =~ ^[Yy]$ || "$NON_INTERACTIVE" = true ]]; then
    FORTUNE_INSTALLED=true
    git clone https://github.com/CupOfTea696/cowsay.git

    if [ -d "cowsay" ]; then
      # shellcheck disable=SC2164
      (
        cd cowsay
        sh install.sh
      )
    fi

    brew install fortune
fi

# Homestead
HOMESTEAD_INSTALLED=false
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Do you want to install laravel/homestead? [y/n] " -n 1 -r
    echo
fi
if [[ $REPLY =~ ^[Yy]$ || "$NON_INTERACTIVE" = true ]]; then
    HOMESTEAD_INSTALLED=true

    ### Installing vagrant, virtualbox, & Homestead
    brew cask install vagrant virtualbox
    vagrant box add laravel/homestead
    git clone https://github.com/laravel/homestead.git ~/Homestead

    (
      cd ~/Homestead
      git checkout release
      bash init.sh
    )
fi

# Cleanup
# shellcheck disable=SC2164
cd ~
rm -rf ~/.tshell_tmp

# zshrc
## Deal with existing zshrc.
if [[ -f ~/.zshrc ]]; then
  if [[ "$NON_INTERACTIVE" = true ]]; then
    mv ~/.zshrc ~/.zshrc.backup
  else
    read -p "Do you want to replace your current .zshrc (recommended)? A backup will be made if you choose yes. If you choose no, the TeaShell rc will be appended instead. [y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        mv ~/.zshrc ~/.zshrc.backup
    fi
  fi
fi

## Config
export INST_IDE="pstorm"
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Configure your IDE [pstorm]`echo $'\n> '`" -r
    echo
    if [[ -n "$REPLY" ]]; then
      INST_IDE="$REPLY"
    fi
fi

export INST_EDITOR="brackets"
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Configure your text editor [brackets]`echo $'\n> '`" -r
    echo
    if [[ -n "$REPLY" ]]; then
      INST_EDITOR="$REPLY"
    fi
fi

export INST_SHELL_EDITOR="nano"
if ! [[ "$NON_INTERACTIVE" = true ]]; then
    read -p "Configure your shell editor [nano]`echo $'\n> '`" -r
    echo
    if [[ -n "$REPLY" ]]; then
      INST_SHELL_EDITOR="$REPLY"
    fi
fi

## Generate rc.
if [[ -d ~/.zsh ]]; then
  echo "The .zsh directory already exists. Replacing it and saving a backup to .zsh.backup"
  mv ~/.zsh ~/.zsh.backup
fi

mkdir ~/.zsh
cd ~/.zsh || (>&2 echo "Failed to create .zsh directory"; exit)

mkdir ~/.zsh/functions
mkdir ~/.zsh/rc

(
  cd "$DIR/lib"
  npm_config_loglevel=error npm install mustache

  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zshrc" >> ~/.zshrc
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zshenv" >> ~/.zshenv

  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/env" >> ~/.zsh/env
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/p10k.zsh" >> ~/.zsh/p10k.zsh
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/plugins.txt" >> ~/.zsh/plugins.txt
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/zshrc" >> ~/.zsh/zshrc

  cp -r "$DIR/tpl/.zsh/hooks" ~/.zsh/hooks
  cp -r "$DIR/tpl/.zsh/internal" ~/.zsh/internal

  cp -r "$DIR/tpl/.zsh/functions/create" ~/.zsh/functions/create
  cp -r "$DIR/tpl/.zsh/functions/edit" ~/.zsh/functions/edit
  cp -r "$DIR/tpl/.zsh/functions/known_hosts" ~/.zsh/functions/known_hosts
  cp -r "$DIR/tpl/.zsh/functions/navigate" ~/.zsh/functions/navigate
  cp "$DIR/tpl/.zsh/functions/finder" ~/.zsh/functions/finder
  cp "$DIR/tpl/.zsh/functions/quick" ~/.zsh/functions/quick
  cp "$DIR/tpl/.zsh/functions/rt3" ~/.zsh/functions/rt3
  cp "$DIR/tpl/.zsh/functions/shell" ~/.zsh/functions/shell
  cp "$DIR/tpl/.zsh/functions/timestamp" ~/.zsh/functions/timestamp

  if [[ "$HOMESTEAD_INSTALLED" = true ]]; then
    cp -r "$DIR/tpl/.zsh/functions/homestead" ~/.zsh/functions/homestead
  fi

  if [[ "$PHP_INSTALLED" = true ]]; then
    cp "$DIR/tpl/.zsh/functions/switch_php" ~/.zsh/functions/switch_php
  fi

  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/rc/aliases" >> ~/.zsh/rc/aliases
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/rc/colors" >> ~/.zsh/rc/colors
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/rc/completion" >> ~/.zsh/rc/completion
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/rc/history" >> ~/.zsh/rc/history
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/rc/keybindings" >> ~/.zsh/rc/keybindings
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/rc/navigation" >> ~/.zsh/rc/navigation
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/rc/opts" >> ~/.zsh/rc/opts
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/rc/paths" >> ~/.zsh/rc/paths
  node env.js | ./node_modules/.bin/mustache - "$DIR/tpl/.zsh/rc/splash" >> ~/.zsh/rc/splash

  rm -rf node_modules package-lock.json
)

# ZSH Plugins
brew install getantibody/tap/antibody
antibody bundle < ~/.zsh/plugins.txt > ~/.zsh/plugins.sh
