#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

as_try() {
  printf "try{%s}catch(e){%s}" "$1" "$2"
}

as_application() {
  printf "Application(\"%s\")" "$1"
}

as_is_running() {
  printf "%s.running()" "$(as_application "$1")"
}

as_if() {
  printf "if(%s){%s}" "$1" "$2"
}
