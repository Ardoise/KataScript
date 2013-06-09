#!/bin/sh

set -e

# Multi-line message, with tabs suppressed
#  The - option to a here document <<-
#+ suppresses leading tabs in the body of the document,
#+ but *not* spaces.
usage ()
{
  cat <<-EOF | sed -e 's/  //g' 
    Usage: $0: [-a] [-b] [-c] [-d] [-v]
          -a : apply a
      -b : apply b
              -c : apply c
        -d : apply d
    -v : verify
EOF
}
usage


#   No parameter substitution when the "limit string" is quoted or escaped.
#   Either of the following at the head of the here document would have
#+  the same effect.
#   cat <<"EndOfMessage"
#   cat <<\EndOfMessage
getfile() 
{
cat /dev/null > /tmp/myfile   # File "/tmp/myfile" now empty. # with fork new process
: > /tmp/myfile               # File "/tmp/myfile" now empty. #   no fork new process        
>> /tmp/myfile                # File "/tmp/myfile" now append, create else

cat <<-\EOF | sed 's/  //g' >/tmp/myfile
    #!/bin/sh
       # Begin myfile
       exec myfile -l "$@"
        # End myfile
EOF

chmod -v 755 /tmp/myfile
}
getfile; cat /tmp/myfile


exit 0
