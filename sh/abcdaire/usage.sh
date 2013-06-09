#!/bin/sh
 
 : ${1?"Usage: $0 ARGUMENT"} # From "usage-message.sh example script.

exit 0

RELEASE="7.2"

USAGE="Usage: $0 [ -hV ] [--help] [--version] arg1"
VERSTR="myprogramm, version ${RELEASE}"

while [ $# -gt 0 ]; do
   case "$1" in
      --help | -h)     help="y"; break ;;

      --version | -V)  echo "${VERSTR}"; exit 0 ;;
   
      -*)              echo "myprogramm: ${1}: invalid option" >&2
                       echo "${USAGE}" >& 2
                       exit 2 ;;
                       
      *)               break ;;
   esac
done

if [ -n "$help" ]; then
   echo "${VERSTR}"
   echo "${USAGE}"
   echo
   cat << HERE_EOF
bla bla ...

HERE_EOF
   exit 0
fi

exit 0
