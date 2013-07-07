#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: flume
# Short-Description: DEPLOY SERVER: [FLUME]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130707
### END INIT INFO

# Description: SERVICE CENTRALLOG: flume (...)
# - deploy flume v1.4.0
#
# Requires : you need root privileges tu run this script
# Requires : JRE7 to run flume
# Requires : curl
#
# CONFIG:   [ "/etc/flume", "/etc/flume/test" ]
# BINARIES: [ "/opt/flume/", "/usr/share/flume/" ]
# LOG:      [ "/var/log/flume/" ]
# RUN:      [ "/var/flume/flume.pid" ]
# INIT:     [ "/etc/init.d/flume" ]

SCRIPT_OK=0
SCRIPT_ERROR=1

DESCRIPTION="FLUME Server";
SCRIPT_NAME=`basename $0`
NAME=flume
DEFAULT=/etc/default/$NAME

#FLUME_CLASSPATH
#flume-env.sh
#$FLUME_HOME/plugins.d

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

cat <<-'EOF' >centralized-flume.getbin.sh
#!/bin/sh -e

[ -d "/opt/flume" ] || sudo mkdir -p /opt/flume;
[ -d "/etc/flume/test" ] || sudo mkdir -p /etc/flume/test;
[ -d "/var/lib/flume" ] || sudo mkdir -p /var/lib/flume;
[ -d "/var/log/flume" ] || sudo mkdir -p /var/log/flume;

SITE=http://www.us.apache.org/dist/flume/1.4.0/
FLUME_PACKAGE=apache-flume-1.4.0-bin.tar.gz;

#gpg --import KEYS
#gpg --verify apache-flume-1.4.0-src.tar.gz.asc

[ -f "${FLUME_PACKAGE}" ] || wget --no-check-certificate $SITE/${FLUME_PACKAGE};
[ -f "${FLUME_PACKAGE}.asc" ] || wget --no-check-certificate $SITE/${FLUME_PACKAGE}.asc;
[ -f "${FLUME_PACKAGE}.md5" ] || wget --no-check-certificate $SITE/${FLUME_PACKAGE}.md5;

#gpg --import KEYS
#echo "66F2054B"
#gpg --verify ${FLUME_PACKAGE}.asc
#cat ${FLUME_PACKAGE}.md5
#md5sum ${FLUME_PACKAGE}

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

case $DISTRIB in
# Ubuntu*|Debian*)
#  echo "apt-get update";
#  echo "apt-get install openjdk-7-jre";
#
#;;
Red*Hat*)
  yum install flume
;;
*)
  [ -e "${FLUME_PACKAGE}" ] && (
    tar xvfz ${FLUME_PACKAGE};
    cd  ${FLUME_PACKAGE%.tar*};
    cp conf/flume-conf.properties.template conf/flume.conf;
    cp conf/flume-env.sh.template conf/flume-env.sh;
    [ -d "/opt/flume/" ] || mkdir -p /opt/flume/;
    [ -d "/opt/flume/" ] && mv * /opt/flume/;
  )
 : 
;;
esac

EOF
chmod a+x centralized-flume.getbin.sh


cat <<'EOF' >centralized-flume.putconf.sh
#!/bin/sh -e

yourIP=$(hostname -I | cut -d' ' -f1);
yourIP=${yourIP:-localhost};

cat <<CEOF >flume-a1.conf
# flume.conf: A single-node Flume configuration
# This configuration defines a single agent named a1. 
# a1 has a source that listens for data on port 44444, 
# a channel that buffers event data in memory, 
# and a sink that logs event data to the console. 

# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = ${yourIP}
a1.sources.r1.port = 44444

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1
CEOF

cat <<CEOF >flume-weblog.conf
# list sources, sinks and channels in the agent
agent_foo.sources = avro-AppSrv-source
agent_foo.sinks = avro-forward-sink
agent_foo.channels = file-channel

# define the flow
agent_foo.sources.avro-AppSrv-source.channels = file-channel
agent_foo.sinks.avro-forward-sink.channel = file-channel

# avro sink properties
agent_foo.sources.avro-forward-sink.type = avro
agent_foo.sources.avro-forward-sink.hostname = 10.1.1.100
agent_foo.sources.avro-forward-sink.port = 10000

# configure other pieces
#...
CEOF

cat <<CEOF >flume-hdfs.conf
# list sources, sinks and channels in the agent
agent_foo.sources = avro-collection-source
agent_foo.sinks = hdfs-sink
agent_foo.channels = mem-channel

# define the flow
agent_foo.sources.avro-collection-source.channels = mem-channel
agent_foo.sinks.hdfs-sink.channel = mem-channel

# avro sink properties
agent_foo.sources.avro-collection-source.type = avro
agent_foo.sources.avro-collection-source.bind = 10.1.1.100
agent_foo.sources.avro-collection-source.port = 10000

# configure other pieces
#...
CEOF

chmod 644 flume-*.conf
[ -d "/etc/flume/test" ] || sudo mkdir -p /etc/flume/test;
[ -d "/etc/flume/test" ] && mv flume-*.conf /etc/flume/test/;

EOF


cat <<EOF >centralized-flume.sh
echo "view /etc/flume/test/flume.conf"
echo "sudo service flume status";
echo "sudo service flume reload";
echo "sudo service flume stop";
echo "sudo service flume start";
echo "sudo service flume restart";

# START AGENT A1 : flume-env.sh
echo "bin/flume-ng agent -n $agent_name -c conf -f conf/flume-conf.properties.template"
echo "bin/flume-ng agent -c conf -f /etc/flume/flume-a1.conf --name a1 -Dflume.root.logger=INFO,console"

EOF


cat <<'EOF' >centralized-flume.test.sh
#!/bin/sh -e

yourIP=$(hostname -I | cut -d' ' -f1);
yourIP=${yourIP:-localhost};

echo "telnet ${yourIP} 44444"

EOF
chmod +x centralized-flume.test.sh


echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-flume : get binaries ..."
sh centralized-flume.getbin.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-flume : get binaries [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-flume : put config ..."
sh centralized-flume.putconf.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-flume : put config [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-flume : start ..."
sh centralized-flume.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-flume : start [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-flume : test ..."
sh centralized-flume.test.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-flume : test [ OK ]"

exit 0
