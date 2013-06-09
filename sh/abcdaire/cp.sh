#!/bin/sh

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  cp file22.{txt,backup}
  # Copies "file22.txt" to "file22.backup" 
*)
 :
;;

exit 0

