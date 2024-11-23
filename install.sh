#!/bin/zsh

# -----------------------------------------------------------------------------
# utility functions
# -----------------------------------------------------------------------------
yellow() {
  echo -e "\033[33m$1\033[m"
}

reset() {
  echo -e "\033[m"
}

# -----------------------------------------------------------------------------
# main functions
# -----------------------------------------------------------------------------

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

# This function installs the Xcode Command Line Tools if they are not already installed.
#
# @See
# https://gist.github.com/mokagio/b974620ee8dcf5c0671f
# http://apple.stackexchange.com/questions/107307/how-can-i-install-the-command-line-tools-completely-from-the-command-line
install_xcode_cli_tools() {
  echo "- 👨🏻‍🚀 Install Xcode CLI tools"
  echo "- 👨🏻‍🚀 Checking Xcode CLI tools..."

  # Check if Xcode CLI tools are already installed by trying to print the SDK path.
  if xcode-select -p &> /dev/null; then
    echo "- 👨🏻‍🚀 Xcode CLI tools are already installed"
  else
    echo "- 👨🏻‍🚀 Xcode CLI tools not found. Installing them..."
    TEMP_FILE="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    touch "${TEMP_FILE}"

    CLI_TOOLS=$(softwareupdate -l \
      | grep "\*.*Command Line" \
      | tail -n 1 | sed 's/^[^C]* //')

    echo "- 👨🏻‍🚀 Installing: ${CLI_TOOLS}"
    softwareupdate -i "${CLI_TOOLS}" --verbose

    rm "${TEMP_FILE}"
    echo "- 👨🏻‍🚀 Xcode CLI tools are ready to go 🎉"
  fi
}

# This function installs Homebrew if it is not already installed.
install_homebrew() {
  echo "- 👨🏻‍🚀 Install Homebrew"
  echo "- 👨🏻‍🚀 Checking Homebrew..."

  if type brew 1>/dev/null 2>&1; then
    echo "- 👨🏻‍🚀 Homebrew is already installed"
  else
    echo "- 👨🏻‍🚀 Homebrew not found"
    echo "- 👨🏻‍🚀 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "- 👨🏻‍🚀 Homebrew is ready to go 🎉"
  fi
}

# This function installs Homebrew Bundle if it is not already installed.
install_homebrew_bundle() {
  echo "- 👨🏻‍🚀 Install Homebrew Bundle"
  echo "- 👨🏻‍🚀 Checking Homebrew Bundle..."

  if brew bundle check; then
    echo "- 👨🏻‍🚀 Homebrew Bundle is already installed"
  else
    echo "- 👨🏻‍🚀 Homebrew Bundle not found"
    echo "- 👨🏻‍🚀 Installing Homebrew Bundle..."
    brew bundle install
    echo "- 👨🏻‍🚀 Homebrew Bundle is ready to go 🎉"
  fi
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


# -----------------------------------------------------------------------------
# Installation
# -----------------------------------------------------------------------------

# Display the welcome message.
yellow
cat << EOF
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝

👨🏻‍🚀 Welcome to the development environment setup!
   This script will install the necessary tools and libraries for development.
EOF

reset

request_admin_privileges
install_xcode_cli_tools
install_homebrew
install_homebrew_bundle
install_prezto

yellow

# Display the completion message.
cat << EOF
 ██████╗ ██████╗ ███╗   ██╗ ██████╗ ██████╗  █████╗ ████████╗███████╗██╗
██╔════╝██╔═══██╗████╗  ██║██╔════╝ ██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║
██║     ██║   ██║██╔██╗ ██║██║  ███╗██████╔╝███████║   ██║   ███████╗██║
██║     ██║   ██║██║╚██╗██║██║   ██║██╔══██╗██╔══██║   ██║   ╚════██║╚═╝
╚██████╗╚██████╔╝██║ ╚████║╚██████╔╝██║  ██║██║  ██║   ██║   ███████║██╗
 ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝


👨🏻‍🚀 Installation completed successfully 🎉
   Please restart your terminal to apply the changes.
EOF
reset