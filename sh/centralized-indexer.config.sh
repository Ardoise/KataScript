#!/bin/bash

cat <<EOF >centralized-indexer.conf
input {
  redis {
    host => "127.0.0.1"
    type => "redis-input"
    # these settings should match the output of the agent
    data_type => "list"
    key => "logstash"

    # We use json_event here since the sender is a logstash agent
    format => "json_event"
  }
}
output {
  stdout { debug => true debug_format => "json"}
  elasticsearch {
    host => "127.0.0.1"
  }
}
EOF

cat <<EOF >centralized-indexer.sh
nohup java -jar logstash-1.1.12-flatjar.jar agent -f centralized-indexer.conf &
EOF
chmod a+x centralized-indexer.sh

exit 0;
