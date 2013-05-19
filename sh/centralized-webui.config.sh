#!/bin/bash

cat <<EOF >centralized-webui.sh
# nohup java -jar logstash-1.1.12-flatjar.jar web --backend elasticsearch://127.0.0.1/ &
nohup java -jar logstash-1.1.12-monolithic.jar web --backend elasticsearch://127.0.0.1/ &
EOF
chmod a+x centralized-webui.sh;
 
exit 0;
