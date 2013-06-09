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
97|98|99)
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
3)
  capitalize_ichar ()          #  Capitalizes initial character
  {                            #+ of argument string(s) passed.
    string0="$@"               # Accepts multiple arguments.
    firstchar=${string0:0:1}   # First character.
    string1=${string0:1}       # Rest of string(s).
    FirstChar=`echo "$firstchar" | tr a-z A-Z`
                               # Capitalize first character.
    echo "$FirstChar$string1"  # Output to stdout.
  }  

  newstring=`capitalize_ichar "every sentence should start with a capital letter."`
  echo "$newstring"          # Every sentence should start with a capital letter.
;;
*)
 : 
;;
esac

exit 0
