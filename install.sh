#!/usr/bin/env bash

set -e

for file in ${HOME}/dotfiles/symlinks/*; do
  [ -r "${file}" ] && [ -e "${file}" ] && rm -f ${HOME}/.`basename ${file}` && ln -s ${file} ${HOME}/.`basename ${file}`
done

if [ ! -e "${HOME}/.gnupg/gpg-agent.conf" ]; then
  echo
  echo Symlinking gpg-agent conf
  mkdir -p "${HOME}/.gnupg"
  ln -s "${HOME}/.gpg-agent.conf" "${HOME}/.gnupg/gpg-agent.conf"
fi

MAC_OS_SSH_CONFIG=""
if [ `uname` == 'Darwin' ]; then
  MAC_OS_SSH_CONFIG="
    UseKeyChain no"
fi

if [ `uname` == 'Darwin' ]; then
  if ! command -v brew > /dev/null 2>&1; then
    echo Installing brew
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    echo
    echo Installing common brew tools
    brew install \
      bash \
      git \
      bash-completion \
      tmux \
      reattach-to-user-namespace \
      fswatch \
      fzf \
      fd \
      htop \
      openssl \
      gnupg \
      pass \
      node \
      graphviz \
      pgcli \
      python

    echo
    echo Installing curl with right option
    brew install curl --with-openssl
    brew link --force curl

    echo
    echo Configuring FZF
    /usr/local/opt/fzf/install

    echo
    echo Configuring Python
    unlink /usr/local/bin/python
    ln -s /usr/local/bin/python3 /usr/local/bin/python
    unlink /usr/local/bin/pip
    ln -s /usr/local/bin/pip3 /usr/local/bin/pip

    echo
    echo Configuring pgcli
    mkdir -p "${HOME}/.config/pgcli"
    ln -s "${HOME}/.pgclirc" "${HOME}/.config/pgcli/config"

    echo
    echo Follow instruction in README for configuring bash
  else
    echo
    echo Updating brew packages

    brew update
    brew upgrade
    brew cleanup
  fi
elif [ `uname` == "Linux" ]; then
  if [ ! -d "${HOME}/.fzf" ]; then
    echo
    echo Installing FZF

    git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
    ${HOME}/.fzf/install
  else
    echo
    echo Updating FZF

    cd ${HOME}/.fzf
    git pull
  fi
fi
