if test -n "$(command -v gdate)"; then
  timer="$(gdate '+%s.%N')"
  cum_time="0.00000000"
  clock() {
    if test -n "$1"; then
      if test "$1" = "-"; then
        printf '\ntotal time: %s\n' "$cum_time" >&2
      else
        time_diff="$(echo "$(gdate '+%s.%N') - $timer" | bc)"
        cum_time="$(echo "$cum_time + $time_diff" | bc)"
        printf '%s [took %s]\n' "$1" "$time_diff" >&2
      fi
    fi
    timer="$(gdate '+%s.%N')"
  }
else
  clock() {
    return
  }
fi

set_tmux_option() {
  local option=$1
  local value=$2
  tmux set-option -gq "$option" "$value"
}

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local option_value="$(tmux show-option -qv "$option")"
  if [ -z "$option_value" ]; then
    option_value="$(tmux show-option -gqv "$option")"
  fi
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

scrolling_text() {
  local text="$1"
  local size="$2"
  local offset="$3"
  local text_length
  if test $# -ge 4; then
    text_length="$4"
  else
    text_length=$(printf "%s" "$text" | wc -m)
  fi
  local index
  local padded_text
  if test "$text_length" -gt "$size"; then
    index=$(( offset % (text_length + 3) ))
    padded_text="$text   $text"
    printf "%s" "$padded_text" | cut -c"$(( index + 1 ))-$(( index + size ))"
  else
    printf "%s" "$text"
  fi
}

to_readable_time() {
  local time="$1"
  printf "%02d:%02d" "$(( time / 60 ))" "$(( time % 60 ))"
}
