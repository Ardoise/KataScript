#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.
 
case "$1" in
1)  
  # Redirecting stderr to stdout fixes this.
  if ls -l nonexistent_filename 2>&1 | grep -q 'No such file or directory'
    then echo "File \"nonexistent_filename\" does not exist."
  fi

;;
*)
 : 
;;
esac

exit 0
