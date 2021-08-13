#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$(dirname "$CURRENT_DIR")/scripts/cache.sh"
source "$(dirname "$CURRENT_DIR")/scripts/applescript.sh"
source "$(dirname "$CURRENT_DIR")/scripts/helpers.sh"

is_running() {
  # Only macOS with osascript command
  if test "$(uname)" = "Darwin" -a -n "$(command -v osascript)"; then
    return 0
  else
    return 1
  fi
}

is_playing() {
  if ! is_running; then
    return 1
  fi

  local player_state="$(get_music_data 'NR==1')"

  if test "$player_state" = "stopped"; then
    return 1
  else
    return 0
  fi
}

get_music_data() {
  _music_data() {
    osascript -l JavaScript "$(dirname "$CURRENT_DIR")/players/applescript.js"
  }

  local music_data="$(_cache_value music_data _music_data)"

  if test -z "$1"; then
    printf "%s" "$music_data" | awk 'NR<=6'
  else
    printf "%s" "$music_data" | awk "$1"
  fi
}

send_command() {
  local remote_command="$1"
  local music_data="$(get_music_data 'NR>5')"
  music_app="$(printf "%s" "$music_data" | awk 'NR==1')"

  if test "$remote_command" = "stop"; then
    action_index="3"
  elif test "$remote_command" = "previous"; then
    action_index="4"
  elif test "$remote_command" = "next"; then
    action_index="5"
  else
    action_index="2"
  fi
  music_action="$(printf "%s" "$music_data" | awk "NR==$action_index")"
  action_command="$(as_try "$(as_if "$(as_is_running "$music_app")" "$(as_application "$music_app").$music_action;")")"
  osascript -l JavaScript -e "$action_command"
}
