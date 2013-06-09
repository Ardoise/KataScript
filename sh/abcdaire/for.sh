#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  # ^ Find all executable files ending in "calc" 
  #+ in /bin and /usr/bin directories.

  # The comma operator can also concatenate strings.
  for file in /{,usr/}bin/*calc; do
    if [ -x "$file" ]; 
      then echo $file 
    fi 
  done
;;
2)
  echo \"{These,words,are,quoted}\" # " prefix and suffix
  # "These" "words" "are" "quoted"
;;
3)
  base64_charset=( {A..Z} {a..z} {0..9} + / = )
  max=${#base64_charset[@]}; echo $max
  for ((a=0;a<=max;a++)); do
    echo -n "${base64_charset[$a]}"
  done
  echo
;;
esac


exit 0
