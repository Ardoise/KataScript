#!/bin/bash

cat <<EOF >distributed-shipper.conf
input{
 # xyz Inputs
 file{
  type => "xyz-stdout-log"
  path => [ "/.../logs/xyz_server1/xyz_server1-stdout.log" ]
}
output{
  stdout { debug => true debug_format => "json"}
  redis{
    host => 'centralizedhost'
    data_type => 'list'
    key => 'logstash-redis'
  }
 
  # stdout{
  # }
}
EOF

cat <<EOF >distributed-shipper.sh
nohup java -jar logstash-1.1.12-flatjar.jar agent -f distributted-shipper.conf > logger-stdout.log 2>&1&
EOF
chmod a+x distributed-shipper.sh

exit 0;
