#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.
 
case "$1" in
1)
  scriptname >filename 
  # redirects the output of scriptname to file filename.
  #+ Overwrite filename if it already exists.

  command &>filename 
  # redirects both the stdout and the stderr of command to filename.
  ;;
2)
  type bogus_command &>/dev/null
  echo $?
  ;;
3)
  command >&2 # redirects stdout of command to stderr .
;;
4)

  # substitution
  (command)>
  <(command)
;;
*)
 : 
;;
esac

exit 0
