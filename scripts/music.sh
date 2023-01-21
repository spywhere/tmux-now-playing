#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/cache.sh"
source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/shada.sh"

players=(
  "$(dirname "$CURRENT_DIR")/players/mpd.sh"
  "$(dirname "$CURRENT_DIR")/players/applescript.sh"
  "$(dirname "$CURRENT_DIR")/players/cscript.sh"
)

is_playing() {
  return 1
}

get_music_data() {
  printf ""
}

send_command() {
  return 1
}

replace() {
  local str="$1"
  local find="$2"
  local replacement="${3//&/\\&}"
  printf '%s' "${str//$find/$replacement}"
}

main() {
  local remote_command=""

  if test "$1" = "--cmd"; then
    remote_command="$2"
  fi

  if test -z "$remote_command" && test -n "$NOW_PLAYING_SHADA"; then
    if has_shared_session; then
      get_shared_status
      exit
    fi
  fi

  local music_data=""

  for ((i=0; i<${#players[@]}; i++)); do
    if test -z "$music_data"; then
      source "${players[$i]}"

      if is_playing; then
        # if running as a remote control
        if test -n "$remote_command"; then
          send_command "$remote_command"
          exit
        fi

        music_data="$(get_music_data)"
      fi
    fi
  done

  if test -z "$music_data"; then
    # no player is running
    printf ""
    if test "$(get_tmux_option "@now-playing-auto-interval" "no")" = "yes"; then
      set_tmux_option "status-interval" "$(get_tmux_option "@now-playing-paused-interval" "5")"
    fi
    exit
  fi

  local player_state="$(printf "%s" "$music_data" | awk 'NR==1')"
  local player_icon="$(get_tmux_option "@now-playing-paused-icon" " ")"

  if test "$player_state" = "playing"; then
    player_icon="$(get_tmux_option "@now-playing-playing-icon" ">")"
  fi

  if test "$(get_tmux_option "@now-playing-auto-interval" "no")" = "yes"; then
    if test "$player_state" = "playing"; then
      set_tmux_option "status-interval" "$(get_tmux_option "@now-playing-playing-interval" "1")"
    else
      set_tmux_option "status-interval" "$(get_tmux_option "@now-playing-paused-interval" "5")"
    fi
  fi

  local track_position="$(printf "%s" "$music_data" | awk 'NR==2')"
  local track_duration="$(printf "%s" "$music_data" | awk 'NR==3')"
  local track_title="$(printf "%s" "$music_data" | awk 'NR==4')"
  local track_title_length="$(printf "%s" "$track_title" | wc -m)"
  local track_artist="$(printf "%s" "$music_data" | awk 'NR==5')"
  local track_artist_length="$(printf "%s" "$track_artist" | wc -m)"
  local app_name="$(printf "%s" "$music_data" | awk 'NR==6')"

  local interpolation_key=(
    "{icon}"
    "{title}"
    "{artist}"
    "{position}"
    "{position_sec}"
    "{duration}"
    "{duration_sec}"
    "{percent}"
    "{app}"
  )
  local interpolation_value=(
    "$player_icon"
    "$track_title"
    "$track_artist"
    "$(to_readable_time "$track_position")"
    "$track_position"
    "$(to_readable_time "$track_duration")"
    "$track_duration"
    "$(( track_position * 100 / track_duration ))"
    "$app_name"
  )
  local scrollable_threshold="$(get_tmux_option "@now-playing-scrollable-threshold" "25")"
  local scrollable_key=(
    "{title}"
    "{artist}"
  )
  local scrolling_tool="scrolling_text"
  if test -n "$(command -v "$(dirname "$CURRENT_DIR")/scroll")"; then
    scrolling_tool="scrolling_text_bin"
  fi

  local default_format="{icon} {scrollable} [{position}/{duration}]"
  local status_format="$(get_tmux_option "@now-playing-status-format" "$default_format")"

  local scrollable_format_key="{scrollable}"
  local scrollable_format="$(get_tmux_option "@now-playing-scrollable-format" "{artist} - {title}")"
  local scrollable_format_whole="$(get_tmux_option "@now-playing-scrollable-format" "{artist} - {title}")"
  local placeholder_length="$(printf "%s" "$scrollable_format" | grep -o '{[^}]*}' | wc -l)"
  local non_placeholder_length="$(printf "%s" "$scrollable_format" | sed 's/{[^}]*}//g' | wc -m)"

  local exceeding_placeholder_count=0
  for ((i=0; i<${#interpolation_key[@]}; i++)); do
    exceeding_count="$(printf "%s" "$scrollable_format" | grep -o "${interpolation_key[$i]}" | wc -l)"
    if test "$(printf "%s" "${interpolation_value[$i]}" | wc -m)" -gt "$scrollable_threshold"; then
      exceeding_placeholder_count=$(( exceeding_placeholder_count + exceeding_count ))
    fi
    status_format="$(replace "$status_format" "${interpolation_key[$i]}" "${interpolation_value[$i]}")"
    scrollable_format_whole="$(replace "$scrollable_format_whole" "${interpolation_key[$i]}" "${interpolation_value[$i]}")"
  done

  if test "$exceeding_placeholder_count" -ge "$placeholder_length"; then
    scrollable_format="$("$scrolling_tool" "$scrollable_format_whole" "$(( placeholder_length * scrollable_threshold + non_placeholder_length ))" "$track_position")"
  else
    local scrollable_value=(
      "$("$scrolling_tool" "$track_title" "$scrollable_threshold" "$track_position" "$track_title_length")"
      "$("$scrolling_tool" "$track_artist" "$scrollable_threshold" "$track_position" "$track_artist_length")"
    )
    for ((i=0; i<${#scrollable_key[@]}; i++)); do
      scrollable_format="$(replace "$scrollable_format" "${scrollable_key[$i]}" "${scrollable_value[$i]}")"
    done
  fi
  status_format="$(replace "$status_format" "$scrollable_format_key" "$scrollable_format")"

  printf "%s" "$status_format"
}

main "$@"
