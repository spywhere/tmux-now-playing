#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"

status_key="\#{now_playing}"

# @now-playing-playing-icon=">"
# @now-playing-playing-icon="▶"
# @now-playing-paused-icon=" "

# @now-playing-auto-interval="yes"
# @now-playing-playing-interval="1"
# @now-playing-paused-interval="5"

# @now-playing-status-format="{icon}{scrollable} [{position}/{duration}]"
# @now-playing-scrollable-format="{artist} - {title}"
# @now-playing-scrollable-threshold="25"

# @now-playing-mpd-host="127.0.0.1"
# @now-playing-mpd-port="6600"

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

  local keys="$(get_tmux_option "@now-playing-pause-key" ",")"
  local key
  for key in $keys; do
    tmux unbind "$key"
    tmux bind-key "$key" run-shell -b "bash $CURRENT_DIR/scripts/music.sh --cmd pause"
  done

  keys="$(get_tmux_option "@now-playing-stop-key" ".")"
  for key in $keys; do
    tmux unbind "$key"
    tmux bind-key "$key" run-shell -b "bash $CURRENT_DIR/scripts/music.sh --cmd stop"
  done

  keys="$(get_tmux_option "@now-playing-stop-key" "\\;")"
  for key in $keys; do
    tmux unbind "$key"
    tmux bind-key "$key" run-shell -b "bash $CURRENT_DIR/scripts/music.sh --cmd previous"
  done

  keys="$(get_tmux_option "@now-playing-stop-key" "'")"
  for key in $keys; do
    tmux unbind "$key"
    tmux bind-key "$key" run-shell -b "bash $CURRENT_DIR/scripts/music.sh --cmd next"
  done
}

main
