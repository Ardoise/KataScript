#!/bin/bash

# {server, service},
# {"distributed", [shipper]},
# {"centralised", [redis, elasticsearch, indexer, shipper]}

cat <<EOF >distributed-shipper.conf
input{
 # xyz Inputs
 file{
  type => "xyz-stdout-log"
  path => [ "/.../logs/xyz_server1/xyz_server1-stdout.log" ]
 }
 file {
  type => "apache-log"
  path => "/var/log/apache2/access.log"
 }
}
filter {
  grok {
    type => "apache-log"
    pattern => "%{COMBINEDAPACHELOG}"
  }
}
output{
  stdout { 
   debug => true 
   debug_format => "json
  }
  redis{
    host => 'centralized'
    data_type => 'list'
    key => 'logstash-redis'
  }
  # greylog
  gelf {
    type => "apache-log"
    host => "localhost"
    facility => "apache"
    level => "INFO"
    sender => "%{@source_host}"
  }
}
EOF

cat <<EOF >distributed-shipper.sh
nohup java -jar logstash-1.1.12-flatjar.jar agent -f distributted-shipper.conf > logger-stdout.log 2>&1&
EOF
chmod a+x distributed-shipper.sh

exit 0;
