#! /usr/bin/env bash

command -v mailx >/dev/null 2>&1 || { echo >&2 "Required command mailx is not installed."; exit 1; }
if ! grep mta $HOME/.mailrc 2>/dev/null | grep smtp 2>/dev/null 1>&2; then
    echo "SMTP must be configured" >&2
    exit 1
fi
CONF=$HOME/.config/mailme.conf
if [ ! -e $CONF ]; then
    echo "Can not find $CONF" >&2
    echo "Example content:" >&2
    echo "ME=mymail@mydomain.org" >&2
    exit 1
fi
source $CONF
if [ -z ${ME+x} ]; then
    echo "Variable ME must be set in $CONF"
    exit 1
fi

tmp="$(mktemp -d)"
cleanup() {
    if [ -d "$tmp" ]; then
        rm -rf "$tmp"
    fi
}
cleanup2() {
    sleep 1
    cleanup
}
trap cleanup2 SIGINT
trap cleanup SIGTERM

mailme() {
  if tty -s; then
      if [ $# -eq 0 ]; then
          echo -e "No arguments specified.\nUsage:\n  $(basename $0) <file|directory>\n  ... | $(basename $0) <file_name>" >&2
        return 1
      fi

    subject=
    if [ $# -eq 1 ]; then
      subject="$*"
    else
      subject="$# files"
    fi
    cmd="mailx -s '$subject'"

    if [ $# -gt 0 ]; then
      while [[ "$1" ]]; do
        if [ ! -e "$1" ]; then
          echo "$1: No such file or directory" >&2
          return 1
        elif [ -d "$1" ]; then
          echo "compressing $1"
          zipped="${tmp}/$(basename "$1").zip"
          (cd "$1" && zip -1 -r -q - .) | cat > "$zipped"
          cmd="$cmd -a '$zipped'"
        else
          cmd="$cmd -a '$1'"
        fi
        shift
      done
      cmd="$cmd $ME"
      echo "sending $subject to $ME"
      saveIFS="$IFS"; IFS=''; date | eval $cmd; IFS="$saveIFS"
    fi
  else
    echo "sending stdin as a body to $ME"
    cat | mailx -s 'stdin' $ME
  fi
}

mailme "$@"
cleanup
