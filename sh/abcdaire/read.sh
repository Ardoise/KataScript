#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case "$1" in
1)
 # Reading lines in /etc/fstab.
 File=/etc/fstab 
 {
 read line1
 read line2
 } <$File

 echo "First line in $File is:"
 echo "$line1"
 echo
 echo "Second line in $File is:"
 echo "$line2"
 
;;
*)
 : 
;;
esac

exit 0

