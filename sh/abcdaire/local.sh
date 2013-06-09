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

*)
 :
;;

exit 0

