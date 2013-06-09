#!/bin/bash

# ^ Find all executable files ending in "calc" 
#+ in /bin and /usr/bin directories.

# The comma operator can also concatenate strings.
for file in /{,usr/}bin/*calc; do
  if [ -x "$file" ]; 
    then echo $file 
  fi 
done 
# /bin/ipcalc 
# /usr/bin/kcalc 
# /usr/bin/oidcalc 
# /usr/bin/oocalc 
# Thank you, Rory Winston, for pointing this out. 

exit 0
