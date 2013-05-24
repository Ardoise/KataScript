#!/bin/bash

# DEPLOY DISTRIBUTED CLIENT : SHIPPER
. ./stdlevel

cat <<EOF >distributed-logstash.getbin.sh
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
chmod a+x distributed-logstash.getbin.sh

# SERVICE CENTRALLOG
# CAS1 : logstash => redis  (test local into distributed)
cat <<"EOF" >distributed-logstash.putconf.sh
cat <<ZEOF >distributed-logstash-logstash2redis.conf
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
  #file {
  #  type => "apache-json"
  #  path => [ "/var/log/httpd/access_json.log" ]
  #}
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
    # batch => ... # boolean (optional), default: false
    # batch_events => ... # number (optional), default: 50
    # batch_timeout => ... # number (optional), default: 5
    # congestion_interval => ... # number (optional), default: 1
    # congestion_threshold => ... # number (optional), default: 0
    # data_type => ... # string, one of ["list", "channel"] (optional)
    # db => ... # number (optional), default: 0
    # exclude_tags => ... # array (optional), default: []
    # fields => ... # array (optional), default: []
    # host => ... # array (optional), default: ["127.0.0.1"]
    # key => ... # string (optional)
    # password => ... # password (optional)
    # port => ... # number (optional), default: 6379
    # reconnect_interval => ... # number (optional), default: 1
    # shuffle_hosts => ... # boolean (optional), default: true
    # tags => ... # array (optional), default: []
    # timeout => ... # number (optional), default: 5
    # type => ... # string (optional), default: ""
    host => "192.168.17.89" 
    data_type => "list"
    key => "logstash-redis"
  }
}
ZEOF

# SERVICE ReadyForUse
[ -d "/etc/logstash" ] && sudo cp distributed-logstash-shipper2redis.conf /etc/logstash/shipper2redis.conf;

EOF
chmod a+x distributed-logstash.putconf.sh

cat <<EOF >distributed-logstash.sh
#!/bin/bash
/etc/init.d/logstash restart
EOF
chmod a+x distributed-logstash.sh

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
