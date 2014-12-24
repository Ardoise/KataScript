#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: elasticsearch
# Short-Description: DEPLOY SERVER: [STORAGESEARCH]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130707
### END INIT INFO

# Description: SERVICE CENTRALLOG: ELASTICSEARCH (NoSQL, INDEX, SEARCH)
# - deploy elasticsearch v0.90.2
# - deploy mobz/elasticsearch-head                plugin
# - deploy karmi/elasticsearch-paramedic          plugin
# - deploy lukas-vlcek/bigdesk                    plugin
# - deploy polyfractal/elasticsearch-inquisitor   plugin
# - deploy polyfractal/elasticsearch-segmentspy   plugin
#
# Requires : you need root privileges tu run this script
# Requires : JRE7 to run elasticsearch
# Requires : curl
#
# CONFIG:   [ "/etc/elasticsearch", "/etc/elasticsearch/test" ]
# BINARIES: [ "/opt/elasticsearch/", "/usr/share/elasticsearch/" ]
# LOG:      [ "/var/log/elasticsearch/" ]
# RUN:      [ "/var/elasticsearch/elasticsearch.pid" ]
# INIT:     [ "/etc/init.d/elasticsearch" ]
# PLUGINS:  [ "/usr/share/elasticsearch/bin/plugin" ]

DESCRIPTION="Elasticsearch Server";
NAME="elasticsearch";

SCRIPT_OK=0;
SCRIPT_ERROR=1;
SCRIPT_NAME=`basename $0`;
DEFAULT=/etc/default/$NAME;
cd $(dirname $0) && SCRIPT_DIR="$PWD" && cd - >/dev/null;
SH_DIR=$(dirname $SCRIPT_DIR);echo "echo SH_DIR=$SH_DIR";
platform="$(lsb_release -i -s)";
platform_version="$(lsb_release -s -r)";

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit $SCRIPT_ERROR
fi

# OWNER
[ -e "${SH_DIR}/lib/usergroup.sh" ] && . ${SH_DIR}/lib/usergroup.sh || exit 1;
uid=$NAME;gid=$NAME;group=devops;pass=$NAME;
usergroup POST;


cat <<"EOF" >centralized-elasticsearch.getbin.sh
#!/bin/sh

[ -d "/opt/elasticsearch" ] || sudo mkdir -p /opt/elasticsearch;
[ -d "/etc/elasticsearch/test" ] || sudo mkdir -p /etc/elasticsearch/test;
[ -d "/var/log/elasticsearch" ] || sudo mkdir -p /var/log/elasticsearch;
[ -d "/var/lib/elasticsearch" ] || sudo mkdir -p /var/lib/elasticsearch;

SITE=https://download.elasticsearch.org/elasticsearch/elasticsearch

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi
  
case $DISTRIB in
Ubuntu*|Debian*)
  echo "sudo apt-get update"
  # echo "sudo apt-get install git rubygems -y"
  # echo "sudo gem install fpm"
  sudo apt-get install openjdk-7-jre-headless wget curl -y
  ES_PACKAGE=elasticsearch-0.20.6.deb;
  ES_PACKAGE=elasticsearch-0.90.0.deb;
  ES_PACKAGE=elasticsearch-0.90.1.deb;
  ES_PACKAGE=elasticsearch-0.90.2.deb;
  [ -f "$ES_PACKAGE" ] || wget --no-check-certificate $SITE/$ES_PACKAGE;
  sudo dpkg -i $ES_PACKAGE;
  sudo service elasticsearch start ;
;;
Redhat*|Red*hat*)
  sudo yum install java-1.7.0-openjdk wget curl -y
  ES_PACKAGE=elasticsearch-0.90.2.noarch.rpm;
  [ -f "$ES_PACKAGE" ] || wget --no-check-certificate $SITE/$ES_PACKAGE;
  sudo rpm -i $ES_PACKAGE;
  sudo service elasticsearch start
;;
*)
  ES_PACKAGE=elasticsearch-0.90.2.zip
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
#!/bin/sh
# Foreground
# elasticsearch -f -Des.network.host=10.0.0.4
# elasticsearch -f -Des.config=/path/to/config/centralized-elasticsearch.yml
# elasticsearch -f -Des.config=/path/to/config/centralized-elasticsearch.json
# elasticsearch -f -Des.index.store.type=memory
# sudo /etc/init.d/elasticsearch start
sudo service elasticsearch start
EOF
chmod a+x centralized-elasticsearch.sh;

# http://www.elasticsearch.org/guide/reference/setup/configuration/
# TODO : http://www.elasticsearch.org/guide/reference/setup/dir-layout/
yourIP=$(hostname -I | cut -d' ' -f1);

[ -d "/etc/elasticsearch/test" ] || sudo mkdir -p "/etc/elasticsearch/test"
cat <<EOF >centralized-elasticsearch.yml
cluster.name: centrallog
node.name: "logstash"
network.host: ${yourIP:="127.0.0.1"}
path.logs: "/var/log/elasticsearch"
path.data: "/var/lib/elasticsearch"
# path.config: "/etc/elasticsearch/elasticsearch"
EOF
[ -d "/etc/elasticsearch/test/" ] && sudo cp centralized-elasticsearch.yml /etc/elasticsearch/test/


cat <<EOF >centralized-elasticsearch.test.sh
#!/bin/sh

# Console
yourIP=$(hostname -I | cut -d' ' -f1);
/etc/init.d/elasticsearch status
ps -efa | grep java | grep elasticsearch
netstat -napt | grep -i LISTEN
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: curl -XGET 'http://${yourIP:="127.0.0.1"}:9200'";
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: curl -XGET 'http://${yourIP:="127.0.0.1"}:9200/_cluster/health?pretty=true'";
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: curl -XGET 'http://${yourIP:="127.0.0.1"}:9200/_cluster/state'";
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: curl -XGET 'http://${yourIP:="127.0.0.1"}:9200/_status?pretty=true'";
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: curl -XGET 'http://${yourIP:="127.0.0.1"}:9200/_search?pretty=1&q=*'";
# http://192.168.19.19:9200/_cluster/nodes/stats
# http://192.168.19.19:9200/_nodes/stats

exit 0;
EOF
chmod a+x centralized-elasticsearch.test.sh

echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-elasticsearch : get binaries ..."
sh centralized-elasticsearch.getbin.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-elasticsearch : get binaries [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-elasticsearch : start service ..."
sh centralized-elasticsearch.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-elasticsearch : start service [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-elasticsearch : test service ..."
sh centralized-elasticsearch.test.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-elasticsearch : test service [ OK ]"


# Plugins

# https://github.com/mobz/elasticsearch-head
[ -f "/usr/share/elasticsearch/bin/plugin" ] && (
  cd /usr/share
  
  echo "elasticsearch-head : web front end for an ElasticSearch cluster"
  echo "http://mobz.github.com/elasticsearch-head "
  sudo elasticsearch/bin/plugin --install mobz/elasticsearch-head
  echo "http://${yourIP}:9200/_plugin/head/"

  echo "A simple tool to inspect the state and statistics about ElasticSearch clusters"
  echo "http://karmi.github.com/elasticsearch-paramedic/"
  sudo elasticsearch/bin/plugin -install karmi/elasticsearch-paramedic
  echo "http://${yourIP}:9200/_plugin/paramedic/index.html"
  
  echo "Bigdesk : Live charts and statistics for elasticsearch cluster"
  echo "To install Bigdesk master branch as an Elasticsearch plugin on a particular Elasticsearch node"
  sudo elasticsearch/bin/plugin --install lukas-vlcek/bigdesk
  echo "http://${yourIP}:9200/_plugin/bigdesk/index.html"

  echo "Inquisitor is a tool help understand and debug your queries in ElasticSearch."
  sudo elasticsearch/bin/plugin -install polyfractal/elasticsearch-inquisitor
  echo "http://${yourIP}:9200/_plugin/inquisitor/index.html"
  
  echo "SegmentSpy is a tool to watch the segments in your indices."
  echo "Segment graphs update in real-time, allowing you to watch as ElasticSearch (Lucene) merges your segments."
  sudo elasticsearch/bin/plugin -install polyfractal/elasticsearch-segmentspy
  echo "http://${yourIP}:9200/_plugin/segmentspy/index.html"
  
  echo "Mapper-attachement"
  echo "The mapper attachments plugin adds the attachment type to ElasticSearch using Tika."
  echo "https://github.com/elasticsearch/elasticsearch-mapper-attachments"
  sudo elasticsearch/bin/plugin -install elasticsearch/elasticsearch-mapper-attachments/1.7.0
  echo "http://${yourIP}:9200/_plugin/mapper/index.html"

  echo "fsriver"
  echo "This river plugin helps to index documents from your local file system."
  echo "https://github.com/dadoonet/fsriver"
  sudo elasticsearch/bin/plugin -install fr.pilato.elasticsearch.river/fsriver/0.2.0
  # sudo elasticsearch/bin/plugin -install fr.pilato.elasticsearch.river/fsriver/0.3.0
  echo "http://${yourIP}:9200/_river/index.html"
  
  echo "ElasticSearch Data Browser"
  echo "The Web front-end over ElasticSearch data written in ExtJS."
  sudo elasticsearch/bin/plugin -install OlegKunitsyn/elasticsearch-browser
  echo "http://${yourIP}:9200/_plugin/browser/?database=logstash-$(date +'%Y.%m.%d')&table=stdin"
)

exit 0
