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
*)
 :
;;

exit 0

