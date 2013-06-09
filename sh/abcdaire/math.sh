#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.
 
case "$1" in
1)
  a=3
  b=7

  echo [$a+$b] # 10
  echo [$a*$b] # 21
  ;;
*)
 : 
;;
esac

exit 0
