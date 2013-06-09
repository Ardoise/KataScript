#!/bin/sh

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  # type file from stdin - stdout
  echo "tape a type file ex: abc or #!/bin/bash"
  file -
 ;;
*)
 :
;;
esac

exit 0

