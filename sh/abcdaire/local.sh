#!/bin/sh

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  a=123
  ( a=321; )	      
  echo "a = $a" # a = 123
  # "a" within parentheses acts like a local variable.

  a=123
  { a=321; }
  echo "a = $a" # a = 321
  # "a" within accolade acts like a global variable.

  a=123
  myfunction () { local a=321; }
  myfunction
  echo "a = $a" # a = 123
  # local "a" within accolade acts like a local variable.

  a=123
  myfunction () { a=321; }
  myfunction
  echo "a = $a" # a = 321
  # "a" within accolade acts like a global variable.

  a=123
  myfunction () { (a=321); }
  myfunction
  echo "a = $a" # a = 123
;;
2)
  TMPFILE=/tmp/tmpfile                  # Create a temp file to store the variable.

  (   # Inside the subshell ...
  inner_variable=Inner
  echo $inner_variable
  echo $inner_variable >>$TMPFILE  # Append to temp file.
  )

      # Outside the subshell ...

  echo; echo "-----"; echo
  echo $inner_variable             # Null, as expected.
  echo "-----"; echo

  # Now ...
  read inner_variable <$TMPFILE    # Read back shell variable.
  rm -f "$TMPFILE"                 # Get rid of temp file.
  echo "$inner_variable"           # It's an ugly kludge, but it works.
;;
*)
 :
;;
esac

exit 0

