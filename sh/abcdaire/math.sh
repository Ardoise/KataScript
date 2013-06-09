#!/bin/bash

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.
 
case "$1" in
1)
  a=3
  b=7

  echo [$a+$b] # 10
  echo [$a*$b] # 21
  ;;
2)
  # multiplication.sh
  multiply ()                     # Multiplies params passed.
  {                               # Will accept a variable number of args.

    local product=1

    until [ -z "$1" ]             # Until uses up arguments passed...
    do
      let "product *= $1"
      shift
    done

    echo $product                 #  Will not echo to stdout,
  }                               #+ since this will be assigned to a variable.

  mult1=15383; mult2=25211
  val1=`multiply $mult1 $mult2`
  # Assigns stdout (echo) of function to the variable val1.
  echo "$mult1 * $mult2 = $val1"                   # 387820813

  mult1=25; mult2=5; mult3=20
  val2=`multiply $mult1 $mult2 $mult3`
  echo "$mult1 * $mult2 * $mult3 = $val2"          # 2500

  mult1=188; mult2=37; mult3=25; mult4=47
  val3=`multiply $mult1 $mult2 $mult3 $mult4`
  echo "$mult1 * $mult2 * $mult3 * $mult4 = $val3" # 8173300

;;
*)
 : 
;;
esac

exit 0
