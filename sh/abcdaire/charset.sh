#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.
 
case "$1" in
1)
  base64_charset=( {A..Z} {a..z} {0..9} + / = )
  # Initializing an array, using extended brace expansion.
  
  for a in ${base64_charset[*]}; do
    echo -n $a;
  done
  echo
;;
{2..9})
  (( var0 = $1<98?9:21 ))
  echo var0=$var0
  # ^ ^

  # if [ "$1" -lt 98 ]
  # then
  # var0=9
  # else
  # var0=21
  # fi
;;
*)
 : 
;;
esac

exit 0
