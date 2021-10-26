#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$(dirname "$CURRENT_DIR")/scripts/cache.sh"
source "$(dirname "$CURRENT_DIR")/scripts/helpers.sh"

is_running() {
  # Only computer with wsl.exe and cscript.exe command
  if test -n "$(command -v wsl.exe)" -a -n "$(command -v wslpath)" -a -n "$(command -v cscript.exe)"; then
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
    cscript.exe '//Nologo' "$(wslpath -w "$(dirname "$CURRENT_DIR")/players/cscript.js")" | sed 's/\r//g'
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
  action_command="if (player) { player.app.$music_action; }"
  tmp_file="$(_get_tmp_dir)/cscript_tmp.js"
  head -n -10 "$(dirname "$CURRENT_DIR")/players/cscript.js" > "$tmp_file"
  printf "%s" "$action_command" | tee -a "$tmp_file" 1>/dev/null
  cscript.exe '//Nologo' "$(wslpath -w "$tmp_file")"
}
