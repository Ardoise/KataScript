#!/bin/sh -e
### BEGIN INIT INFO
# Provides:          graylog2
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Graylog2 script
# Description:       graylog2 script for deploy.
### END INIT INFO

SCRIPT_OK=0
SCRIPT_ERROR=1

DESCRIPTION="Graylog2 Server";
SCRIPT_NAME=`basename $0`
NAME=graylog2
DEFAULT=/etc/default/$NAME
cd $(dirname $0) && SCRIPT_DIR="$PWD" && cd - >/dev/null
SH_DIR=$(dirname $SCRIPT_DIR);echo "echo SH_DIR=$SH_DIR"
platform="$(lsb_release -i -s)"
platform_version="$(lsb_release -s -r)"

[ -e "${SH_DIR}/lib/usergroup.sh" ] && . ${SH_DIR}/lib/usergroup.sh || exit 1;

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit $SCRIPT_ERROR
fi

# OWNER
uid=$NAME;gid=$NAME;group=devops
usergroup POST;

# GrayLog2
[ -d "/etc/graylog2" ] || sudo mkdir -p "/etc/graylog2";

cat <<EOF >centralized-graylog2.getbin.sh
#!/bin/sh
[ -s "graylog2-server-0.11.0.tar.gz" ] || curl -O http://download.graylog2.org/graylog2-server/graylog2-server-0.11.0.tar.gz
  tar xvfz graylog2-server-0.11.0.tar.gz
  cd graylog2-server-0.11.0
    sudo cp graylog2.conf.example /etc/graylog2/graylog2.conf.ori
    sudo cp elasticsearch.yml.example /etc/graylog2/graylog2-elasticsearch.yml.ori
    [ -e "/etc/graylog2.conf" ] || sudo cp graylog2.conf.example /etc/graylog2.conf
    [ -e "/etc/graylog2-elasticsearch.yml" ] || sudo cp elasticsearch.yml.example /etc/graylog2-elasticsearch.yml
  cd -
EOF
chmod a+x centralized-graylog2.getbin.sh

cat <<EOF >centralized-graylog2.sh
#!/bin/sh

. ./stdlevel

if [ -e "/etc/graylog2.conf" ]; then
# -h, --help: Show help message
# -f CONFIGFILE, --configfile CONFIGFILE: Use configuration file CONFIGFILE for graylog2; default: /etc/graylog2.conf
# -t, --configtest: Validate graylog2 configuration and exit with exit code 0 if the configuration file is syntactically correct, exit code 1 and a description of the error otherwise
# -d, --debug: Run in debug mode
# -l, --local: Run in local mode. Automatically invoked if in debug mode. Will not send system statistics, even if enabled and allowed. Only interesting for development and testing purposes.
# -s, --statistics: Print utilization statistics to STDOUT
# -r, --no-retention: Do not automatically delete old/outdated indices
# -p PIDFILE, --pidfile PIDFILE: Set the file containing the PID of graylog2 to PIDFILE; default: /tmp/graylog2.pid
# -np, --no-pid-file: Do not write PID file (overrides -p/--pidfile)
# --version: Show version of graylog2 and exi
  cd graylog2-server-0.11.0
    nohup java -jar graylog2-server.jar --configfile /etc/graylog2.conf --debug > glogger-stdout.log 2>&1&
  cd -
else
  err "/etc/graylog2.conf introuvable";
fi
EOF
chmod a+x centralized-graylog2.sh

cat <<EOF >centralized-graylog2.test.sh
# graylog2.conf
is_master = true
# elasticsearch_config_file = /etc/elasticsearch/graylog2-elasticsearch.yml
# elasticsearch_config_file = /etc/graylog2-elasticsearch.yml
elasticsearch_config_file = /etc/elasticsearch/elasticsearch.yml
elasticsearch_max_docs_per_index = 20000000
elasticsearch_max_number_of_indices = 20
elasticsearch_shards = 4
elasticsearch_replicas = 0
recent_index_ttl_minutes = 60
mongodb_*
# Exception in thread "main" java.lang.RuntimeException: Could not authenticate to database 'graylog2' with user 'grayloguser'
# MongoDB Configuration
mongodb_useauth = false
mongodb_user = grayloguser
mongodb_password = 123
mongodb_host = 127.0.0.1

# graylog2-elasticsearch.yml
cluster.name: graylog2
discovery.zen.ping.multicast.enabled: false
discovery.zen.ping.unicast.hosts: ["127.0.0.1:9300"]
echo "<34> Hello Graylog2. Let's be friends." | nc -w 1 -u localhost 514
EOF
chmod a+x centralized-graylog2.test.sh

# config
# http://support.torch.sh/help/kb/graylog2-server/installing-graylog2-server-on-debian-6

exit 0;
