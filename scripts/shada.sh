#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_NAME="tmux"

source "$CURRENT_DIR/helpers.sh"

self_priority() {
  get_tmux_option "@now-playing-shared-session-priority" "0"
}

get_command() {
  get_tmux_option "@now-playing-shared-session-command" ""
}

active_commands() {
  tmux list-panes -a -F '#{pane_current_command}' -f '#{window_active}'
}

string_contain() {
  test -z "${1##*$2*}"
  return $?
}

read_shada() {
  awk "NR==$1" "$NOW_PLAYING_SHADA"
}

write_shada() {
  printf '%s\n%s\n%s' "$(self_priority)" "$APP_NAME" "$(date '+%s')" > "$NOW_PLAYING_SHADA"
}

get_shared_status() {
  # return interpolated string with app
  printf '%s' "$(get_tmux_option "@now-playing-shared-session" "")"
}

has_shared_session() {
  if ! test -f "$NOW_PLAYING_SHADA"; then
    # no data
    write_shada
    return 1
  fi

  local command="$(get_command)"

  if test -n "$command"; then
    local has_take_over=0
    for active_cmd in $(active_commands); do
      if string_contain "$command" "$active_cmd"; then
        has_take_over=1
      fi
    done

    if test "$has_take_over" -eq 0; then
      return 1
    fi
  fi

  local priority="$(read_shada 1)"

  if test "$priority" -lt "$(self_priority)"; then
    # self has higher priority
    write_shada
    return 1
  fi

  local app="$(read_shada 2)"
  local time="$(read_shada 3)"
  local now="$(date '+%s')"

  if test "$app" = "$APP_NAME"; then
    # data is self produced

    if test "$now" -ge "$(( time + 5 ))"; then
      # update every 5 sec
      write_shada
    fi

    return 1
  fi

  if test "$now" -ge "$(( time + 10 ))"; then
    # data is too old
    return 1
  fi

  return 0
}
