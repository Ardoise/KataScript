#!/bin/sh

cat <<EOF >centralized-system.cntrl.sh
# CONTROL PORTS
netstat -napt | grep -i LISTEN
EOF
chmod a+x centralized-system.cntrl.sh

exit 0;
