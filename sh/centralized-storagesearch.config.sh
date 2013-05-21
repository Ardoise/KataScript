#!/bin/bash

# DEPLOY CENTRALIZED SERVER : STORAGESEARCH
. ./stdlevel

cat <<"EOF" >centralized-elasticsearch.getbin.sh
#!/bin/sh

SITE=https://download.elasticsearch.org/elasticsearch/elasticsearch
  
case $@ in
*ubuntu*)
  sudo apt-get update
  sudo apt-get install openjdk-7-jre-headless wget curl -y
  ES_PACKAGE=elasticsearch-0.20.6.deb;
  ES_PACKAGE=elasticsearch-0.90.0.deb;
  wget --no-check-certificate $SITE/$ES_PACKAGE;
  sudo dpkg -i $ES_PACKAGE;
  sudo service elasticsearch start ;
;;
*redhat*)
  sudo yum install java-1.7.0-openjdk wget curl -y
  ES_PACKAGE=elasticsearch-0.90.0.RC2.noarch.rpm;
  wget --no-check-certificate $SITE/$ES_PACKAGE;
  sudo rpm -i $ES_PACKAGE;
  sudo service elasticsearch start
;;
*)
  ES_PACKAGE=elasticsearch-0.90.0.zip
  ES_DIR=${ES_PACKAGE%%.zip}
  if [ ! -d "$ES_DIR" ] ; then
    wget --no-check-certificate $SITE/$ES_PACKAGE;
    unzip $ES_PACKAGE;  
  fi
;;
esac
EOF
chmod a+x centralized-elasticsearch.getbin.sh;

cat <<EOF >centralized-elasticsearch.sh
# Foreground
# elasticsearch -f -Des.network.host=10.0.0.4
# elasticsearch -f -Des.config=/path/to/config/centralized-elasticsearch.yml
# elasticsearch -f -Des.config=/path/to/config/centralized-elasticsearch.json
# elasticsearch -f -Des.index.store.type=memory
sudo /etc/rc.d/init.d/elasticsearch start
EOF
chmod a+x centralized-elasticsearch.sh;

cat <<EOF >centralized-elasticsearch.conf
output {
  elasticsearch {
    # bind_host => 127.0.0.1 # string (optional)
    # cluster => centrallog # string (optional)
    document_id => nil # string (optional), default: nil
    embedded => false # boolean (optional), default: false
    embedded_http_port => "9200-9300" # string (optional), default: "9200-9300"
    exclude_tags => [] # array (optional), default: []
    fields => [] # array (optional), default: []
    # host => ... # string (optional)
    index => "logstash-%{+YYYY.MM.dd}" # string (optional), default: "logstash-%{+YYYY.MM.dd}"
    index_type => "%{@type}" # string (optional), default: "%{@type}"
    max_inflight_requests => 50 # number (optional), default: 50
    # node_name => ... # string (optional)
    port => "9300-9400" # number (optional), default: "9300-9400"
    tags => [] # array (optional), default: []
    type => "" # string (optional), default: ""
  }
}
EOF

cat <<"EOF" >centralized-elasticsearch-log4j.yml
# config/logging.yml
rootLogger: INFO, console, file
logger:
  # log action execution errors for easier debugging
  action: DEBUG
  # reduce the logging for aws, too much is logged under the default INFO
  com.amazonaws: WARN

  # gateway
  #gateway: DEBUG
  #index.gateway: DEBUG

  # peer shard recovery
  #indices.recovery: DEBUG

  # discovery
  #discovery: TRACE

  index.search.slowlog: TRACE, index_search_slow_log_file
  index.indexing.slowlog: TRACE, index_indexing_slow_log_file

additivity:
  index.search.slowlog: false
  index.indexing.slowlog: false

appender:
  console:
    type: console
    layout:
      type: consolePattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"

  file:
    type: dailyRollingFile
    file: ${path.logs}/${cluster.name}.log
    datePattern: "'.'yyyy-MM-dd"
    layout:
      type: pattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"

  index_search_slow_log_file:
    type: dailyRollingFile
    file: ${path.logs}/${cluster.name}_index_search_slowlog.log
    datePattern: "'.'yyyy-MM-dd"
    layout:
      type: pattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"

  index_indexing_slow_log_file:
    type: dailyRollingFile
    file: ${path.logs}/${cluster.name}_index_indexing_slowlog.log
    datePattern: "'.'yyyy-MM-dd"
    layout:
      type: pattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"
EOF

# http://www.elasticsearch.org/guide/reference/setup/configuration/
# TODO : http://www.elasticsearch.org/guide/reference/setup/dir-layout/
[ -f "/opt/elasticsearch/config/elasticsearch.yml" ] && cat "/opt/elasticsearch/config/elasticsearch.yml"
cat <<EOF >centralized-elasticsearch.yml
cluster.name: centrallog
node.name: "logstash"                 # graylog2
network.host: 127.0.0.1               # 192.168.x.x | 10.x.x.x
path.logs: "/var/log/elasticsearch"
path.data: "/var/lib/elasticsearch"   # /var/data/elasticsearch
EOF

# http://www.elasticsearch.org/guide/reference/setup/configuration/
cat <<EOF >centralized-elasticsearch.json
{
  "network" : {
    // elasticsearch -f -Des.network.host=10.0.0.4
    // "host" : "${ES_NET_HOST}"
    "host" : "10.0.0.4"
  }
  "path" : {
    "logs" : "/var/log/elasticsearch"
    "data" : "/var/data/elasticsearch"
  }
  "cluster" : {
    "name" : "centrallog"
  }
  "node" : {
    "name" : "logstash"
  }
}
EOF

cat <<EOF >centralized-elasticsearch.test.sh
# Console
sudo /etc/init.d/elasticsearch status
ps -efa | grep java | grep elasticsearch
netstat -napt | grep -i LISTEN
curl -XGET 'http://localhost:9200'
curl -XGET 'http://localhost:9200/_cluster/health?pretty=true'
curl -XGET 'http://localhost:9200/_cluster/state'
curl -s 'http://127.0.0.1:9200/_status?pretty=true'
# Index
# curl -XPUT http://127.0.0.1:9200/logstash/ -d 
# '
# index :
#     store:
#         type: memory
# '
EOF
chmod a+x centralized-elasticsearch.test.sh

exit 0
