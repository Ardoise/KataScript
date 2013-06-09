#!/bin/sh -x

 : 
echo $?  # 0

not_empty () {
 : 
} 
# Contains a : (null command), and so is not empty.

exit 0
