#!/bin/bash

# DEPLOY CENTRALIZED SERVER : INDEXER

. ./stdlevel

cat <<EOF >centralized-logstash.getbin.sh
#!/bin/sh

[ -d "/var/lib/logstash" ] || sudo mkdir -p /var/lib/logstash ;
[ -d "/var/log/logstash" ] || sudo mkdir -p /var/log/logstash ;
[ -d "/etc/logstash" ] || sudo mkdir -p /etc/logstash ;
[ -d "/opt/logstash" ] || sudo mkdir -p /opt/logstash ;
sudo cd /opt/logstash
  [ -s "logstash-1.1.12-flatjar.jar" ] || curl -OL https://logstash.objects.dreamhost.com/release/logstash-1.1.12-flatjar.jar
  [ -s "logstash-1.1.11.dev-monolithic.jar" ] || curl -OL http://logstash.objects.dreamhost.com/builds/logstash-1.1.11.dev-monolithic.jar
cd -
EOF
chmod a+x centralized-logstash.getbin.sh

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
    embedded => false
    host => "127.0.0.1"
    cluster => "centrallog"
  }
}
EOF

cat <<EOF >centralized-indexer.sh
#!/bin/sh
nohup java -jar logstash-1.1.12-flatjar.jar agent -f ./centralized-indexer.conf > ilogger-stdout.log 2>&1&
EOF
chmod a+x centralized-indexer.sh

cat <<EOF >centralized-indexer.test.sh
#!/bin/sh
echo -n $(date '+%d/%m/%Y %r')
curl -s -XGET http://127.0.0.1:9200/logstash-$(date '+%Y.%m.%d')/_search?q=@type:stdin-type
EOF
chmod a+x centralized-indexer.test.sh

exit 0;
