 #!/bin/sh

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.
 
case "$1" in
1)
  if condition
  then : # Do nothing and branch ahead
  else # Or else ...
    take-some-action
  fi
;;
[0-9][2-9])
  (( var0 = $1<98?9:21 ))
  echo var0=$var0
  # ^ ^

  # if [ "$1" -lt 98 ]
  # then
  # var0=9
  # else
  # var0=21
  # fi
;;
*)
 : 
;;
esac
  