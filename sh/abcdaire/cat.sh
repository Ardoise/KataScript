#!/bin/sh

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case "$1" in
1)
  cat {file1,file2,file3} > combined_file
  # Concatenates the files file1, file2, and file3 into combined_file.
;;
2)
  cat *.lst | sort | uniq
  # Merges and sorts all ".lst" files, then deletes duplicate lines.
;;
3)
  echo "redirection from/to stdin or stdout [dash]. <ctrl-D> to exit"
  cat -
;;
*)
 :
;;
esac

exit 0
