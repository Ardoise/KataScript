#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  : > -badname
  ls -l
  # -rw-r--r-- 1 bozo bozo 0 Nov 25 12:29 -badname
  rm -- -badname
  ls -l
;;
2)
  rm -f *.sh~
;;
*)
 :
;;
esac

exit 0    	


