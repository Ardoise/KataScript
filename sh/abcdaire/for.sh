#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  # ^ Find all executable files ending in "calc" 
  #+ in /bin and /usr/bin directories.

  # The comma operator can also concatenate strings.
  for file in /{,usr/}bin/*calc; do
    if [ -x "$file" ]; 
      then echo $file 
    fi 
  done
;;
2)
  echo \"{These,words,are,quoted}\" # " prefix and suffix
  # "These" "words" "are" "quoted"
;;
3)
  base64_charset=( {A..Z} {a..z} {0..9} + / = )
  max=${#base64_charset[@]}; echo $max
  for ((a=0;a<=max;a++)); do
    echo -n "${base64_charset[$a]}"
  done
  echo
;;
4)

 # background-loop.sh
 for i in 1 2 3 4 5 6 7 8 9 10 # First loop.
 do
   echo -n "$i "
 done & # Run this loop in background.
        # Will sometimes execute after second loop
 echo # This 'echo' sometimes will not display.

 for i in A B C D E F G H I J # Second loop.
 do
   echo -n "$i "
 done
 echo # This 'echo' sometimes will not display.

 # ======================================================

 # The expected output from the script:
 # 1 2 3 4 5 6 7 8 9 10 
 # 11 12 13 14 15 16 17 18 19 20 

 # Sometimes, though, you get:
 # 11 12 13 14 15 16 17 18 19 20 
 # 1 2 3 4 5 6 7 8 9 10 bozo $
 # (The second 'echo' doesn't execute. Why?)

 # Occasionally also:
 # 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
 # (The first 'echo' doesn't execute. Why?)

 # Very rarely something like:
 # 11 12 13 1 2 3 4 5 6 7 8 9 10 14 15 16 17 18 19 20 
 # The foreground loop preempts the background one.

 # Nasimuddin Ansari suggests adding sleep 1
 #+ after the echo -n "$i" in lines 6 and 14,
 #+ for some real fun. 
;;
esac


exit 0
