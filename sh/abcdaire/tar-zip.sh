#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case "$1" in
1)
  bunzip2 -c linux-3.8.0-23.tar.bz2 | tar xvf -
  #  --uncompress tar file--      | --then pass it to "tar"--
  #  If "tar" has not been patched to handle "bunzip2",
  #+ this needs to be done in two discrete steps, using a pipe.
  #  The purpose of the exercise is to unarchive "bzipped" kernel source. 
;;
*)
 : 
;;
esac

exit 0


