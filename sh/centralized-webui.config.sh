#!/bin/bash

cat <<EOF >centralized-webui.sh
# nohup java -jar logstash-1.1.12-flatjar.jar web --backend elasticsearch://127.0.0.1/ &
nohup java -jar logstash-1.1.12-monolithic.jar web --backend elasticsearch://127.0.0.1/ &
EOF
chmod a+x centralized-webui.sh;

cat <<EOF >centralized-elasticsearch.cntrl.sh
# CONTROL PORTS
netstat -napt | grep -i LISTEN
EOF
chmod a+x centralized-elasticsearch.cntrl.sh

exit 0
