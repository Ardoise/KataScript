#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.
 
case "$1" in
1)
  CMD=command1                 # First choice.
  PlanB=command2               # Fallback option.

  command_test=$(whatis "$CMD" | grep 'nothing appropriate')
  #  If 'command1' not found on system , 'whatis' will return
  #+ "command1: nothing appropriate."
  #
  #  A safer alternative is:
  #     command_test=$(whereis "$CMD" | grep \/)
  #  But then the sense of the following test would have to be reversed,
  #+ since the $command_test variable holds content only if
  #+ the $CMD exists on the system.
  #     (Thanks, bojster.)


  if [[ -z "$command_test" ]]  # Check whether command present.
  then
    $CMD option1 option2       #  Run command1 with options.
  else                         #  Otherwise,
    $PlanB                     #+ run command2. 
  fi
;;
*)
 : 
;;
esac

exit 0

