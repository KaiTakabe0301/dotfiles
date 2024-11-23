#!/bin/zsh

# This function requests the user's password to grant sudo access for the script.
request_admin_privileges() {
  echo -e "- 👨🏻‍🚀 Please enter your password to grant sudo access for this operation."
  sudo -v

  # Keep-alive: update existing `sudo` time stamp until `install.sh` has finished.
  while true; do
    sudo -n true;
    sleep 60;
    kill -0 "$$" || exit;
  done 2>/dev/null &
}

install_prezto() {
  echo "- 👨🏻‍🚀 Install Prezto"
  echo "- 👨🏻‍🚀 Checking Prezto..."

  if [ -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
    echo "- 👨🏻‍🚀 Prezto is already installed"
  else
    echo "- 👨🏻‍🚀 Prezto not found"
    echo "- 👨🏻‍🚀 Installing Prezto..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    echo "- 👨🏻‍🚀 Prezto is ready to go 🎉"

    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
      ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done
  fi
}

request_admin_privileges
install_prezto
