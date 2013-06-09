#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.
 
case "$1" in
1)
  base64_charset=( {A..Z} {a..z} {0..9} + / = )
  # Initializing an array, using extended brace expansion.

  max=${#base64_charset[@]}; echo $max
  for ((a=0;a<=max;a++)); do
    echo -n "${base64_charset[$a]}"
  done
  echo
  
  unset a
  
  for a in ${base64_charset[*]}; do
    echo -n $a;
  done
  echo
;;
*)
 : 
;;
esac

exit 0
