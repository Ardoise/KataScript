#!/bin/sh

# DEPLOY CENTRALIZED SERVER : BROKER, INDEXER, SHIPPER, STORAGESEARCH, WEBUI
. ./stdlevel

cat <<EOF >centralized-logstash.getbin.sh
#
[ -d "/opt/logstash/patterns" ] || sudo mkdir -p /opt/logstash/patterns ;
[ -d "/var/lib/logstash" ] || sudo mkdir -p /var/lib/logstash ;
[ -d "/var/log/logstash" ] || (
  sudo mkdir -p /var/log/logstash ;
  chmod 755 /var/log/logstash ;
)
[ -d "/etc/logstash" ] || sudo mkdir -p /etc/logstash ;
sudo cd /opt/logstash
[ -s "logstash-1.1.12-flatjar.jar" ] || curl -OL https://logstash.objects.dreamhost.com/release/logstash-1.1.12-flatjar.jar
[ -s "logstash-1.1.11.dev-monolithic.jar" ] || curl -OL http://logstash.objects.dreamhost.com/builds/logstash-1.1.11.dev-monolithic.jar
EOF
chmod a+x centralized-logstash.getbin.sh

# SERVICE CENTRALLOG
# CAS1 : logstash => elasticsearch  (test local into centralized)
# CAS2 : logstash => redis          (test local into broker)
cat <<"EOF" >centralized-logstash.putconf.sh
cat <<ZEOF >centralized-logstash-shipper2elasticsearch.conf
input {
  file {
    type => "linux-syslog"
    #path => [ "/var/log/syslog" , "/var/log/messages" ]
    #path => [ "/var/log/syslog" ]  #Ubuntu
    path => [ "/var/log/messages" ] #CentOS,RHEL
  }
  file {
    type => "apache-access"
    #path => [ "/var/log/httpd/access_log", "/var/log/apache2/access.log" ]
    #path => [ "/var/log/apache2/access.log" ] #Ubuntu
    path => [ "/var/log/httpd/access_log" ] #CentOS,RHEL
  }
  file {
    type => "apache-error"
    #path => [ "/var/log/httpd/error_log", "/var/log/apache2/error.log" ]
    #path => [ "/var/log/apache2/error.log" ] #Ubuntu
    path => [ "/var/log/httpd/error_log" ] #CentOS,RHEL
  }
}
output {
  stdout {
    #only for mode DEBUG
  }
  elasticsearch {
    embedded => false         #another process elasticsearch
    host => "192.168.17.89"   #see elasticsearch.yml
    cluster => "centrallog"   #see elasticsearch.yml
  }
}
ZEOF

cat <<ZEOF >centralized-logstash-shipper2redis.conf
input {
  file {
    type => "linux-syslog"
    #path => [ "/var/log/syslog" , "/var/log/messages" ]
    #path => [ "/var/log/syslog" ]  #Ubuntu
    path => [ "/var/log/messages" ] #CentOS,RHEL
  }
  file {
    type => "apache-access"
    #path => [ "/var/log/httpd/access_log", "/var/log/apache2/access.log" ]
    #path => [ "/var/log/apache2/access.log" ] #Ubuntu
    path => [ "/var/log/httpd/access_log" ] #CentOS,RHEL
  }
  file {
    type => "apache-error"
    #path => [ "/var/log/httpd/error_log", "/var/log/apache2/error.log" ]
    #path => [ "/var/log/apache2/error.log" ] #Ubuntu
    path => [ "/var/log/httpd/error_log" ] #CentOS,RHEL
  }
}
filter {
  # grok {
    # type => "linux-syslog"       #type "syslog"
    # pattern => "%{SYSLOGLINE}"
  # }
  # multiline{
    # type => "xyz-stdout-log"
    # pattern => "^\s"
    # what => previous
  # }
}
output {
  stdout {
    #only for mode DEBUG
  }
  #AMQP
  redis {
    host => "192.168.17.89" 
    data_type => "list" 
    key => "logstash-redis"
  }
}
ZEOF

cat <<ZEOF >centralized-logstash-redis2elasticsearch.conf
input {
  redis {
    host => "192.168.17.89" 
    type => "redis-input"
    data_type => "list" 
    key => "logstash-redis"
    # We use json_event here since the sender is a logstash agent
    format => "json_event"
  }
}
output {
  stdout {
    #only for mode DEBUG
  }
  elasticsearch {
    embedded => false         #another process elasticsearch
    host => "192.168.17.89"   #see elasticsearch.yml
    cluster => "centrallog"   #see elasticsearch.yml
  }
}
ZEOF

# SERVICE ReadyForUse
#[ -d "/etc/logstash" ] && sudo cp centralized-logstash-shipper2elasticsearch.conf /etc/logstash/shipper2elasticsearch.tmp;
[ -d "/etc/logstash" ] && sudo cp centralized-logstash-shipper2redis.conf /etc/logstash/shipper2redis.conf;
[ -d "/etc/logstash" ] && sudo cp centralized-logstash-redis2elasticsearch.conf /etc/logstash/redis2elasticsearch.conf;

EOF
chmod a+x centralized-logstash.putconf.sh

cat <<EOF >centralized-logstash.sh
#!/bin/bash
# -Des.path.data="/var/lib/elasticsearch/"
# logstash-1.1.9-monolithic.jar
nohup java -jar /opt/logstash/logstash-1.1.12-flatjar.jar agent -vvv -f /etc/logstash/redis.conf -l /var/log/logstash/redis.log 2>&1&
nohup java -jar /opt/logstash/logstash-1.1.12-flatjar.jar agent -vvv -f /etc/logstash/elasticsearch.conf -l /var/log/logstash/elasticsearch.log 2>&1&
# NEXT
# /etc/init.d/logstash force-reload
# /etc/init.d/logstash restart
EOF
chmod a+x centralized-logstash.sh

cat <<EOF >centralized-logstash.test.sh
curl -XGET http://192.168.17.89:9200/_status?pretty=true
curl -XGET http://192.168.17.89:9200/logstash-2013.05.23/_status?pretty=true
EOF
chmod a+x centralized-logstash.test.sh

cat <<"EOF" >etc-init.d-logstash
#! /bin/sh
#
# /etc/rc.d/init.d/logstash
#
# Starts Logstash as a daemon
#
# chkconfig: 2345 20 80
# description: Starts Logstash as a daemon
# pidfile: /var/run/logstash-agent.pid

### BEGIN INIT INFO
# Provides: logstash
# Required-Start: $local_fs $remote_fs
# Required-Stop: $local_fs $remote_fs
# Default-Start: 2 3 4 5
# Default-Stop: S 0 1 6
# Short-Description: Logstash
# Description: Starts Logstash as a daemon.
# Author: christian.paredes@sbri.org, modified by https://github.com/paul-at
# Update: ardoise.gisement@gmail.com, modified by https://github.com/Ardoise/KataScript/sh

### END INIT INFO

# Amount of memory for Java
JAVAMEM=256M

# Location of logstash files
LOCATION=/opt/logstash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
DESC="Logstash Daemon"
NAME=java
DAEMON=`which java`
# MONO-FILE SHIPPER
# CONFIG_DIR="/etc/logstash/logstash.conf"
# MULTI-FILE SHIPPER
CONFIG_DIR="/etc/logstash/"
LOGFILE="/var/log/logstash/logstash.log"
PATTERNSPATH="/opt/logstash/patterns"
#JARNAME=logstash-monolithic.jar
JARNAME=logstash-1.1.12-flatjar.jar
ARGS="-Xmx$JAVAMEM -Xms$JAVAMEM -jar ${JARNAME} agent --config ${CONFIG_DIR} --log ${LOGFILE} --grok-patterns-path ${PATTERNSPATH}"
SCRIPTNAME=/etc/init.d/logstash
base=logstash

# Exit if the package is not installed
if [ ! -x "$DAEMON" ]; then
{
  echo "Couldn't find $DAEMON"
  exit 99
}
fi

. /etc/init.d/functions

#
# Function that starts the daemon/service
#
do_start()
{
  cd $LOCATION && \
  ($DAEMON $ARGS &) \
  && success || failure
}

#
# Function that stops the daemon/service
#
do_stop()
{
  #pid=`ps auxww | grep 'logstash.*monolithic' | grep java | awk '{print $2}'`
  pid=`ps auxww | grep 'logstash.*flatjar' | grep java | awk '{print $2}'`
  if checkpid $pid 2>&1; then
    # TERM first, then KILL if not dead
    kill -TERM $pid >/dev/null 2>&1
    usleep 100000
    if checkpid $pid && sleep 1 &&
      checkpid $pid && sleep $delay &&
      checkpid $pid ; then
      kill -KILL $pid >/dev/null 2>&1
      usleep 100000
    fi
  fi
  checkpid $pid
  RC=$?
  [ "$RC" -eq 0 ] && failure $"$base shutdown" || success $"$base shutdown"
}

case "$1" in
  start)
    echo -n "Starting $DESC: "
    do_start
    touch /var/lock/subsys/$JARNAME
  ;;
  stop)
    echo -n "Stopping $DESC: "
    do_stop
    rm /var/lock/subsys/$JARNAME
  ;;
  restart|reload)
    echo -n "Restarting $DESC: "
    do_stop
    do_start
  ;;
  status)
    status -p $PID
  ;;
  *)
    echo "Usage: $SCRIPTNAME {status|start|stop|status|restart}" >&2
    exit 3
  ;;
esac

echo
exit 0
EOF
chmod 755 etc-init.d-logstash
exit 0;
