#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  # No spaces allowed within the braces unless the spaces are quoted or escaped.
  echo {file1,file2}\ :{\ A," B",' C'}
  # file1 : A file1 : B file1 : C file2 : A file2 : B file2 : C 
;;
2)
 echo {a..z} # abcdefghijklmnopqrstu vwxyz
 # Echoes characters between a and z.

 echo {0..3} # 0 1 2 3
 # Echoes characters between 0 and 3.
*)
 :
;;
esac

exit 0    	

