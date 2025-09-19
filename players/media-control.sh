#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$(dirname "$CURRENT_DIR")/scripts/cache.sh"
source "$(dirname "$CURRENT_DIR")/scripts/helpers.sh"

INCLUDE_MUSIC="$(get_tmux_option "@now-playing-media-control-include-music-app" "yes")"

include_music() {
  case "$INCLUDE_MUSIC" in
    yes|true|1) return 0 ;;
    *) return 1 ;;
  esac
}

is_running() {
  if test -n "$(command -v media-control)"; then
    return 0
  else
    return 1
  fi
}

is_playing() {
  if ! is_running; then
    return 1
  fi

  local json_data="$(media-control get 2>/dev/null)"
  if test $? -ne 0 || test -z "$json_data"; then
    return 1
  fi

  local playback_rate="$(printf "%s" "$json_data" | jq -r '.playbackRate // 0' 2>/dev/null)"
  local bundle_id="$(printf "%s" "$json_data" | jq -r '.bundleIdentifier // ""' 2>/dev/null)"

  if test "$playback_rate" = "0" || test "$playback_rate" = "null"; then
    return 1
  elif test "$bundle_id" = "com.apple.Music" && ! include_music; then
    return 1
  else
    return 0
  fi
}

get_music_data() {
  local json_data="$(media-control get 2>/dev/null)"
  
  if test $? -ne 0 || test -z "$json_data"; then
    printf "stopped\n0\n0\n\n\nmedia-control"
    return
  fi

  local playback_rate="$(printf "%s" "$json_data" | jq -r '.playbackRate // 0' 2>/dev/null)"
  local position="$(printf "%s" "$json_data" | jq -r '.position // 0' 2>/dev/null | awk '{print int($0)}')"
  local duration="$(printf "%s" "$json_data" | jq -r '.duration // 0' 2>/dev/null | awk '{print int($0)}')"
  local title="$(printf "%s" "$json_data" | jq -r '.title // ""' 2>/dev/null)"
  local artist="$(printf "%s" "$json_data" | jq -r '.artist // ""' 2>/dev/null)"

  local status="playing"
  if test "$playback_rate" = "0" || test "$playback_rate" = "null"; then
    status="paused"
  fi

  printf "%s\n%s\n%s\n%s\n%s\nmedia-control" "$status" "$position" "$duration" "$title" "$artist"
}

send_command() {
  local remote_command="$1"
  case "$remote_command" in
    "pause"|"playpause")
      media-control toggle-play-pause
      ;;
    "stop")
      media-control pause
      ;;
    "previous")
      media-control previous-track
      ;;
    "next")
      media-control next-track
      ;;
    *)
      # Default to toggle play/pause for unknown commands
      media-control toggle-play-pause
      ;;
  esac
}
