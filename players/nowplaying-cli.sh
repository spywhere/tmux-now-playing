#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$(dirname "$CURRENT_DIR")/scripts/cache.sh"
source "$(dirname "$CURRENT_DIR")/scripts/helpers.sh"

is_running() {
  if test -n "$(command -v nowplaying-cli)"; then
    return 0
  else
    return 1
  fi
}

is_playing() {
  if ! is_running; then
    return 1
  fi

  local playback_rate="$(nowplaying-cli get playbackRate)"

  if test "$playback_rate" = "null"; then
    return 1
  else
    return 0
  fi
}

get_music_data() {
  local music_data="$(nowplaying-cli get playbackRate elapsedTime duration title artist)"

  local playback_rate="$(printf "%s" "$music_data" | awk 'NR==1{ print $0 }')"
  local position="$(printf "%s" "$music_data" | awk 'NR==2{ print int($0) }')"
  local duration="$(printf "%s" "$music_data" | awk 'NR==3{ print int($0) }')"
  local title="$(printf "%s" "$music_data" | awk 'NR==4{ print $0 }')"
  local artist="$(printf "%s" "$music_data" | awk 'NR==5{ print $0 }')"

  local status="playing"
  if test "$playback_rate" = "0"; then
    status="paused"
  fi

  printf "%s\n%s\n%s\n%s\n%s\nnowplaying-cli" "$status" "$position" "$duration" "$title" "$artist"
}

send_command() {
  local remote_command="$1"
  if test "$remote_command" = "pause"; then
    nowplaying-cli togglePlayPause
  elif test "$remote_command" = "stop"; then
    # nowplaying-cli don't support stop
    nowplaying-cli pause
  else
    nowplaying-cli "$remote_command"
  fi
}
