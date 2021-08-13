#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$(dirname "$CURRENT_DIR")/scripts/cache.sh"
source "$(dirname "$CURRENT_DIR")/scripts/helpers.sh"

MPD_HOST="$(get_tmux_option "@now-playing-mpd-host" "127.0.0.1")"
MPD_PORT="$(get_tmux_option "@now-playing-mpd-port" "6600")"

is_running() {
  if ! test -n "$(command -v nc)"; then
    return 1
  fi
  if (printf "close\n" | nc "$MPD_HOST" "$MPD_PORT" | grep -q "OK MPD"); then
    return 0
  else
    return 1
  fi
}

is_playing() {
  if ! is_running; then
    return 1
  fi

  _mpd_status() {
    sh -c "(printf \"status\nclose\n\"; sleep 0.05) | nc \"$MPD_HOST\" \"$MPD_PORT\""
  }

  local mpd_status="$(_cache_value mpd_status _mpd_status)"
  local mpd_state="$(printf "%s" "$mpd_status" | awk '$1 ~ /^state:/ { print $2 }')"

  if test "$mpd_state" = "stop"; then
    return 1
  fi

  return 0
}

get_music_data() {
  _mpd_data() {
    sh -c "(printf \"status\ncurrentsong\nclose\n\"; sleep 0.05) | nc \"$MPD_HOST\" \"$MPD_PORT\""
  }

  local mpd_data="$(_cache_value mpd_data _mpd_data)"

  local mpd_state="$(printf "%s" "$mpd_data" | awk '$1 ~ /^state:/ { print $2 }' | cut -d':' -f1)"
  local position="$(printf "%s" "$mpd_data" | awk '$1 ~ /^time:/ { print $2 }' | cut -d':' -f1)"
  local duration="$(printf "%s" "$mpd_data" | awk '$1 ~ /^time:/ { print $2 }' | cut -d':' -f2)"
  local title="$(printf "%s" "$mpd_data" | awk '$1 ~ /^Title:/ { print $0 }' | cut -d':' -f2- | sed 's/^ *//g')"
  local artist="$(printf "%s" "$mpd_data" | awk '$1 ~ /^Artist:/ { print $0 }' | cut -d':' -f2- | sed 's/^ *//g')"

  local status=""
  if test "$mpd_state" = "play"; then
    status="playing"
  elif test "$mpd_state" = "pause"; then
    status="paused"
  fi

  printf "%s\n%s\n%s\n%s\n%s\nMPD" "$status" "$position" "$duration" "$title" "$artist"
}

send_command() {
  sh -c "(printf \"$1\nclose\n\"; sleep 0.05) | nc \"$MPD_HOST\" \"$MPD_PORT\"" > /dev/null
}
