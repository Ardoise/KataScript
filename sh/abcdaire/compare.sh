#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.
 
case "$1" in
1)
 veg1=carrots
 veg2=tomatoes

 if [[ "$veg1" < "$veg2" ]]
 then
   echo "Although $veg1 precede $veg2 in the dictionary,"
   echo -n "this does not necessarily imply anything "
   echo "about my culinary preferences."
 else
   echo "What kind of dictionary are you using, anyhow?"
 fi
;;
2)

 if [ $file1 -ot $file2 ]
 then # ^
   echo "File $file1 is older than $file2."
 fi

 if [ "$a" -eq "$b" ]
 then # ^
   echo "$a is equal to $b."
 fi

 if [ "$c" -eq 24 -a "$d" -eq 47 ]
 then # ^ ^
   echo "$c equals 24 and $d equals 47."
 fi

 param2=${param1:-$DEFAULTVAL}
 
;;
*)
 : 
;;
esac

echo

exit 0


