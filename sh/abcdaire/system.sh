#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.
 
case "$1" in
1)

  : <<COMMENT
  A shell script may act as an embedded command inside another shell script, 
  a Tcl or wish script, or even a Makefile. 
  It can be invoked as an external shell command 
  in a C program using the system() call,
COMMENT

  # call the script C
  system("script_name");
;;
*)
 : 
;;
esac

exit 0

