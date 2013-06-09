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
4)
  echo "this text write itself into stdout" | cat -
;;
5)
  # Write into the first line
  file=/tmp/data ; : >>$file.txt
  title="***This is the title line of data text file***"

  echo $title | cat - $file.txt >$file.new
  # "cat -" concatenates stdout to $file.
  #  End result is
  #+ to write a new file with $title appended at *beginning*.

  cat $file.txt
  cat $file.new
;;
*)
 :
;;
esac

exit 0
