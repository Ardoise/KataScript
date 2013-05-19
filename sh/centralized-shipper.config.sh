#!/bin/bash

cat <<EOF >centralized-shipper.conf
input {
  stdin {
    type => "stdin-type"
  }
}
output {
  stdout { 
    debug => true 
    debug_format => "json"
  }
  # shipper local
  redis { 
    host => "127.0.0.1" 
    data_type => "list" 
    key => "logstash-redis"
  }
  # GreyLog2
  gelf {
    type => "apache-log"
    host => "127.0.0.1"
    facility => "apache"
    level => "INFO"
    sender => "%{@source_host}"
  }
 }
EOF

cat <<EOF >centralized-shipper.sh
#nohup sudo java -jar logstash-1.1.12-monolithic.jar agent -f centralized-shipper.conf > logger-stdout.log 2>&1&
nohup java -jar logstash-1.1.12-flatjar.jar agent -f centralized-shipper.conf > logger-stdout.log 2>&1&
EOF
chmod a+x centralized-shipper.sh

exit 0;
