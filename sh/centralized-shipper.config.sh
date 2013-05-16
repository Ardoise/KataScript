#!/bin/bash

cat <<EOF >centralized-shipper.conf
input {
  stdin {
    type => "stdin-type"
  }
}
output {
  stdout { debug => true debug_format => "json"}
  redis { host => "127.0.0.1" data_type => "list" key => "logstash" }
}
EOF

cat <<EOF >centralized-shipper.sh
nohup java -jar logstash-1.1.12-flatjar.jar agent -f centralized-shipper.conf &
EOF
chmod a+x centralized-shipper.sh
