#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"

cd "${DIR}/../.home"

stow -v -R -t "$HOME" .

ln -s "$HOME/.gtkrc-2.0" "$HOME/.gtkrc-2.0-kde4"

cd "${DIR}/.."

stow -v -R -t "$HOME/.config" .

cd "${DIR}/../.kde"

stow -v -R -t "$HOME/.config" .
