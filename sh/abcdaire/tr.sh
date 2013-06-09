#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case "$1" in
1)
  # uppercase.sh : Changes input to uppercase.
  tr '[:lower:]' '[:upper:]'
  # Letter ranges must be quoted
  #+ to prevent filename generation from single-letter filenames.
  
;;
2)
  ls -l | tr '[:lower:]' '[:upper:]'
  ls -l | tr a-z A-Z

;;
*)
 : 
;;
esac

exit 0

