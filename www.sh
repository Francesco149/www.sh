#!/bin/busybox ash

alias tr='busybox tr'
alias awk='busybox awk'
alias rm='busybox rm'
alias wc='busybox wc'
alias cat='busybox cat'
alias dirname='busybox dirname'
alias mktemp='busybox mktemp'
alias realpath='busybox realpath'
alias echo='busybox echo'

dir=$(dirname "$0")
wdir=$(realpath "$dir")
wwwdir=$(realpath "$wdir/www")

errcho() { (>&2 echo "${@}") }

handle() {
  read -r req
  [ -z "$req" ] && return
  errcho "$req"
  while read -r line; do # consume rest to avoid connection reset
    [ -z "$(echo "$line" | tr -d '[:space:]')" ] && break
  done
  url=$(echo "$req" | awk '{ print $2 }')
  file=$(echo "$url" | awk -F '[#?]' '{ print $1 }')
  params=$(echo "$url" | awk -F '[#?]' '{ print $2 }')
  file=$(realpath "$wwwdir/$file")
  if [ -d "$file" ]; then
    for f in "$file"/index.*; do
      if [ -f "$f" ]; then
        file="$f"
      fi
    done
  fi
  case "$file" in
    "$wwwdir"*)
      if [ ! -f "$file" ]; then
        echo "HTTP/1.1 404 Not Found"
        file=./404.sh
      else
        echo "HTTP/1.1 200 OK"
      fi
      ;;
    *)
      echo "HTTP/1.1 403 Forbidden"
      file=./403.sh
      ;;
  esac
  output="$file"
  if [ -x "$file" ]; then
    output=$(mktemp ./tmp.XXXXXX)
    "$file" "$params" > "$output"
  else
    case "$file" in
      *.ms)
        output=$(mktemp ./tmp.XXXXXX)
        groff -ms "$file" -Thtml -P -V > "$output"
        ;;
    esac
  fi
  echo "Content-Length: $(wc -c < "$output")"
  echo
  cat "$output"
  if [ "$output" != "$file" ]; then
    rm "$output"
  fi
}

www() {
  while true; do
    busybox nc -ll -p "${1:-8080}" -e "$(realpath "$0")" handle
  done
}

olddir="$(pwd)"
cd "$wdir" || exit
if [ "$1" = "handle" ]; then
  handle
else
  www "$@"
fi
cd "$olddir" || exit
