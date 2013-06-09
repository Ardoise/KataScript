#!/bin/sh +x

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  sleep 5 & echo "done"
   # wait 5s
;;
*)
 :
;;
esac

exit 0    	


