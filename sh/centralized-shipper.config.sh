#!/bin/bash

# DEPLOY CENTRALIZED SERVER : SHIPPER
. ./stdlevel

cat <<EOF >centralized-vhost.conf
LogFormat "{ \"@timestamp\": \"%{%Y-%m-%dT%H:%M:%S%z}t\", \"@fields\": { \"client\": \"%a\", \"duration_usec\": %D, \"status\": %s, \"request\": \"%U%q\", \"method\": \"%m\", \"referrer\": \"%{Referer}i\" } }" logstash_json
# Write our 'logstash_json' logs to logs/access_json.log
CustomLog logs/access_json.log logstash_json
EOF
[ -d "/etc/logstash" ] || mkdir -p ./etc/logstash;
[ -d "/etc/logstash" ] && cp centralized-vhost.conf ./etc/logstash/
[ -d "/etc/apache2/conf.d/" ] && (
  sudo cp centralized-vhost.conf /etc/apache2/conf.d/;
  sudo apachectl configtest;
)


cat <<EOF >centralized-shipper.conf
input {
  stdin {
    type => "stdin-type"
  }
  file { 
    path => "/var/log/httpd/access_json.log" 
    type => apache 
    # This format tells logstash to expect 'logstash' json events from the file.
    format => json_event 
  }
}
filter {
  # GreyLog2
  grok {
    type => "apache-log"
    pattern => "%{COMBINEDAPACHELOG}"
  }
}
output {
  stdout { 
    debug => true 
    debug_format => "json"
  }
  # send flowing : test local
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
[ -d "/etc/logstash" ] || mkdir -p ./etc/logstash;
[ -d "/etc/logstash" ] && cp centralized-shipper.conf ./etc/logstash/


cat <<EOF >centralized-shipper.sh
#!/bin/sh
#nohup sudo java -jar logstash-1.1.12-monolithic.jar agent -f ./centralized-shipper.conf > logger-stdout.log 2>&1&
nohup java -jar logstash-1.1.12-flatjar.jar agent -f ./centralized-shipper.conf > logger-stdout.log 2>&1&
EOF
chmod a+x centralized-shipper.sh

cat <<EOF >centralized-shipper.test.sh
#!/bin/sh
ps -efa | grep logstash | grep -v "grep"
EOF
chmod a+x centralized-shipper.test.sh

exit 0;
