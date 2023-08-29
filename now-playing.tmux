#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"

status_key="\#{now_playing}"

do_interpolation() {
  local interpolated_text="$1"
  local value="#($CURRENT_DIR/scripts/music.sh)"
  echo "${interpolated_text//${status_key}/${value}}"
}

update_tmux_option() {
  local option=$1
  local option_value=$(get_tmux_option "$option")
  local new_option_value=$(do_interpolation "$option_value")
  set_tmux_option "$option" "$new_option_value"
}

main() {
  update_tmux_option "status-right"
  update_tmux_option "status-left"

  local keytable="$(get_tmux_option "@now-playing-keytable" "prefix")"

  local keys="$(get_tmux_option "@now-playing-play-pause-key" ",")"
  local key
  for key in $keys; do
    tmux unbind -T "$keytable" "$key"
    tmux bind-key -T "$keytable" "$key" run-shell -b "bash $CURRENT_DIR/scripts/music.sh --cmd pause"
  done

  keys="$(get_tmux_option "@now-playing-stop-key" ".")"
  for key in $keys; do
    tmux unbind -T "$keytable" "$key"
    tmux bind-key -T "$keytable" "$key" run-shell -b "bash $CURRENT_DIR/scripts/music.sh --cmd stop"
  done

  keys="$(get_tmux_option "@now-playing-previous-key" "\\;")"
  for key in $keys; do
    tmux unbind -T "$keytable" "$key"
    tmux bind-key -T "$keytable" "$key" run-shell -b "bash $CURRENT_DIR/scripts/music.sh --cmd previous"
  done

  keys="$(get_tmux_option "@now-playing-next-key" "'")"
  for key in $keys; do
    tmux unbind -T "$keytable" "$key"
    tmux bind-key -T "$keytable" "$key" run-shell -b "bash $CURRENT_DIR/scripts/music.sh --cmd next"
  done
}

main
