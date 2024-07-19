#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$(dirname "$CURRENT_DIR")/scripts/cache.sh"
source "$(dirname "$CURRENT_DIR")/scripts/helpers.sh"

INCLUDE_MUSIC="$(get_tmux_option "@now-playing-nowplaying-cli-include-music-app" "no")"

include_music() {
  case "$INCLUDE_MUSIC" in
    yes|true|1) return 0 ;;
    *) return 1 ;;
  esac
}

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

  local data="$(nowplaying-cli get playbackRate isMusicApp)"
  local playback_rate="$(printf "%s" "$data" | awk 'NR==1{ print $0 }')"
  local is_music_app="$(printf "%s" "$data" | awk 'NR==2{ print $0 }')"

  if test "$playback_rate" = "null"; then
    return 1
  elif test "$is_music_app" = "1" && ! include_music; then
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
