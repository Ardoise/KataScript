#!/bin/sh

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  while :
  do
    operation-1
    operation-2
    ...
    operation-n
  done

  # Same as:
  # while true
  # do
  # ...
  # done
  ;;
2)
  while [ -n "$1" ]; do
		if type -path "$1" >/dev/null 2>/dev/null ; then
			echo "bla bla : $1"
			return 0
		fi
		shift
  done
  ;;
*)
  :
  ;;
esac

exit 0


