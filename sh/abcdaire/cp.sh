#!/bin/sh

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  cp file22.{txt,backup}
  # Copies "file22.txt" to "file22.backup"
;;
2)
  cp -a /source/directory/* /source/directory/.[^.]* /dest/directory
  # If there are hidden files in /source/directory.

;;
*)
 :
;;
esac

exit 0

