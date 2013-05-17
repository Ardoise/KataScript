#!/bin/bash


cat <<"EOF" >centralized-elasticsearch.getbin.sh
#!/bin/sh
ES_PACKAGE=elasticsearch-0.20.5.zip
ES_DIR=${ES_PACKAGE%%.zip}
SITE=https://download.elasticsearch.org/elasticsearch/elasticsearch
if [ ! -d "$ES_DIR" ] ; then
  wget --no-check-certificate $SITE/$ES_PACKAGE;
  unzip $ES_PACKAGE;  
fi
EOF
chmod a+x centralized-elasticsearch.getbin.sh;

cat <<EOF >centralized-elasticsearch.web.sh
# Foreground
sudo /etc/rc.d/init.d/elasticsearch start

# Backend
# nohup java -jar logstash-1.1.12-flatjar.jar web --backend elasticsearch://127.0.0.1/ &
nohup java -jar logstash-1.1.12-monolithic.jar web --backend elasticsearch://127.0.0.1/ &
EOF
chmod a+x centralized-elasticsearch.web.sh;

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

cat "/opt/elasticsearch/config/elasticsearch.yml"
cat <<EOF >centralized-elasticsearch.yml
cluster.name: centrallog
EOF

cat <<EOF >centralized-elasticsearch.uri.sh
curl -s http://127.0.0.1:9300/
curl -s http://127.0.0.1:9200/_status?pretty=true | grep logstash
curl -s -XGET http://127.0.0.1:9200/logstash-2013.05.14/_search?q=@type:stdin
curl -s -XGET http://127.0.0.1:9292/search
# CONTROL PORTS
netstat -napt | grep -i LISTEN
EOF
chmod a+x centralized-elasticsearch.uri.sh

cat <<EOF >centralized-elasticsearch.cntrl.sh
# CONTROL PORTS
netstat -napt | grep -i LISTEN
EOF
chmod a+x centralized-elasticsearch.cntrl.sh

exit 0
