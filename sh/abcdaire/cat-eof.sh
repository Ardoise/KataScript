#!/bin/sh

# PATTERNS

set -e

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


getfile() 
{
cat <<-"EOF" | sed 's/  //g' >/tmp/myfile
    #!/bin/sh
       # Begin myfile
       exec myfile -l "$@"
        # End myfile
EOF

chmod -v 755 /tmp/myfile
}
getfile

exit 0
