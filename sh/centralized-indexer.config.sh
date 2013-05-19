#!/bin/bash

cat <<EOF >centralized-indexer.conf
input {
  redis {
    host => "127.0.0.1"
    type => "redis-input"
    # these settings should match the output of the agent
    data_type => "list"
    key => "logstash-redis"

    # We use json_event here since the sender is a logstash agent
    format => "json_event"
  }
}

filter {
  grok {
    type => "producer" # for logs of type "syslog"
    pattern => "%{SYSLOGLINE}"
    # You can specify multiple 'pattern' lines
  }
  multiline{
    type => "xyz-stdout-log"
    pattern => "^\s"
    what => previous
  }
  multiline{
    type => "xyz-server1-log"
    pattern => "^\s"
    what => previous
  }
}

output {
  stdout { 
    debug => true 
    debug_format => "json"
  }
  elasticsearch {
    host => "127.0.0.1"
  }
}
EOF

cat <<EOF >centralized-indexer.sh
nohup java -jar logstash-1.1.12-flatjar.jar agent -f centralized-indexer.conf &
EOF
chmod a+x centralized-indexer.sh

cat <<EOF >centralized-indexer.test.sh
echo -n $(date '+%d/%m/%Y %r')
curl -s -XGET http://127.0.0.1:9200/logstash-$(date '+%Y.%m.%d')/_search?q=@type:stdin-type
EOF
chmod a+x centralized-indexer.test.sh

exit 0;
