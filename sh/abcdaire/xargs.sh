#!/bin/sh

 : ${1?"Usage: $0 <NUMBER>"} # From "usage-message.sh example script.

case $1 in
1)
  # -t : print command before exec them
  ls .  | xargs -i -t file ./{} ;
 ;;
2)
  # liste ds users
  cut -d: -f1 < /etc/passwd | sort | xargs echo 
;;
3)
  # Generates a compact listing of all the users on the system.
  xargs sh -c 'emacs "$@" < /dev/tty' emacs
;;
4)
  find /tmp -name core -type f -print0 | xargs -0 /bin/rm -f
  # Find files named core in or below the directory /tmp and delete them, 
  #+ processing filenames in such  a  way
  #+ that file or directory names containing spaces 
  #+ or newlines are correctly handled.
;;
5)
  : <<-COMMENT
  When  you use the -I option, each line read from the input is buffered internally.   This means that there
  is an upper limit on the length of input line that xargs will accept when used with  the  -I  option.   To
  work  around  this limitation, you can use the -s option to increase the amount of buffer space that xargs
  uses, and you can also use an extra invocation of xargs to ensure that very long lines do not occur.   For
  example:

  somecommand | xargs -s 50000 echo | xargs -I '{}' -s 100000 rm '{}'

  Here,  the  first invocation of xargs has no input line length limit because it doesn't use the -i option.
  The second invocation of xargs does have such a limit, but we have ensured that the it never encounters  a
  line  which  is longer than it can handle.   This is not an ideal solution.  Instead, the -i option should
  not impose a line length limit, which is why this discussion appears in the  BUGS  section.   The  problem
  doesn't occur with the output of find(1) because it emits just one filename per line.
COMMENT

;;
*)
 :
;;
esac

exit 0
