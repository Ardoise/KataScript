#!/bin/sh

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  ls -ail .;
  ls -1 .
 ;;
*)
 :
;;
esac

exit 0

