#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cs_application() {
  printf "Application(\"%s\")" "$1"
}

cs_is_running() {
  printf "%s.running()" "$(as_application "$1")"
}

cs_if() {
  printf "if(%s){%s}" "$1" "$2"
}
