#!/bin/sh -e
### BEGIN INIT INFO
# Provides: logstash shipper
# Short-Description: DEPLOY SERVER: [SHIPPER]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130531
### END INIT INFO

# Description: SERVICE DISTRIBUTED CLIENT LOG: LOGSTASH (shipper)
# - deploy logstash v1.1.13
#
# Requires : you need root privileges tu run this script
# Requires : JRE7 to run logstash
# Requires : curl
#
# CONFIG: [ "/etc/logstash", "/etc/logstash/test" ]
#   logstash => redis (centralized)
# BINARIES: [ "/opt/logstash/" ]
# LOG:      [ "/var/log/logstash/" ]
# RUN:      [ "/var/run/logstash.pid" ]
# INIT:     [ "/etc/init.d/logstash" ]

SCRIPT_NAME=`basename $0`
NAME=logstash
DESC="logstash Server"
DEFAULT=/etc/default/$NAME
cd $(dirname $0) && SCRIPT_DIR="$PWD" && cd - >/dev/null
SH_DIR=$(dirname $SCRIPT_DIR);echo "echo SH_DIR=$SH_DIR"
platform="$(lsb_release -i -s)"
platform_version="$(lsb_release -s -r)"

[ -e "${SH_DIR}/lib/usergroup.sh" ] && . ${SH_DIR}/lib/usergroup.sh || exit 1;

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

# OWNER
uid=$NAME;gid=$NAME;group=devops
usergroup POST;

# TODO : USE IT !
[ -e "/lib/lsb/init-functions" ] && . /lib/lsb/init-functions
[ -r /etc/default/rcS ] && . /etc/default/rcS
. ./stdlevel; # DEPRECATED

cat <<EOF >distributed-logstash.getbin.sh
#!/bin/sh
[ -d "/opt/logstash/patterns" ] || sudo mkdir -p /opt/logstash/patterns ;
[ -d "/opt/logstash/test" ] || sudo mkdir -p /opt/logstash/test ;
[ -d "/var/lib/logstash" ] || sudo mkdir -p /var/lib/logstash ;
[ -d "/var/log/logstash" ] || (
  sudo mkdir -p /var/log/logstash ;
  chmod 755 /var/log/logstash ;
)
[ -d "/etc/logstash/test" ] || sudo mkdir -p /etc/logstash/test ;
cd /opt/logstash
[ -s "logstash-1.1.13-flatjar.jar" ] || curl -OL https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jar
EOF
chmod a+x distributed-logstash.getbin.sh

cat <<"EOF" >distributed-logstash.putconf.sh
#!/bin/sh

yourIP=$(hostname -I | cut -d' ' -f1);

[ -d "/etc/logstash/test" ] || sudo mkdir -p /etc/logstash/test;
cat <<ZEOF >distributed-logstash-stdin2stdout.conf
input {
  stdin {
    #add_field => {}        # hash (optional), default: {}
    charset => "UTF-8"      # "ISO8859-1"... "locale", "external", "filesystem", "internal"
    debug => true
    # format =>             # string, one of ["plain", "json", "json_event", "msgpack_event"] (optional)
    # message_format =>     # string (optional)
    #tags => []             # array (optional)
    type => "stdin"         # string (required)
  }
}
output {
  stdout {
    debug => true           # METHOD : READ THE FIRST ELEMENT
    debug => false          # 2013-05-30T18:46:55.029Z stdin://localhost/: yourmessage
                            # message => "%{@timestamp} %{@source}: %{@message}"

    debug_format => "json"  # {"@source":"stdin://localhost/","@tags":[],"@fields":{},"@timestamp":"2013-05-30T18:53:00.744Z","@source_host":"localhost","@source_path":"/","@message":"test","@type":"stdin"}

    debug_format => "ruby"  # {
                            #          "@source" => "stdin://localhost/",
                            #            "@tags" => [],
                            #          "@fields" => {},
                            #       "@timestamp" => "2013-05-30T18:50:19.367Z",
                            #      "@source_host" => "localhost",
                            #     "@source_path" => "/",
                            #         "@message" => "",
                            #            "@type" => "stdin"
                            # }

    debug_format => "dots"  # .

    # exclude_tags => []      # array (optional)
    # fields => []            # array (optional)
    # message => "%{@timestamp} %{@source}: %{@message}"
    # tags => []              # array (optional)
    type => "stdout"   # string (optional), default: ""
  }
}
ZEOF
[ -d "/etc/logstash/test" ] && sudo cp distributed-logstash-stdin2stdout.conf /etc/logstash/test/stdin2stdout.conf;


[ -d "/etc/logstash/test" ] || sudo mkdir -p /etc/logstash/test;
cat <<ZEOF >distributed-logstash-shipper2redis.conf
input {
  file {
    type => "linux-syslog"
    path => [ "/var/log/syslog" , "/var/log/messages" ]
    #path => [ "/var/log/syslog" ]  #Ubuntu
    #path => [ "/var/log/messages" ] #CentOS,RHEL
  }
  file {
    type => "apache-access"
    path => [ "/var/log/httpd/access_log", "/var/log/apache2/access.log" ]
    #path => [ "/var/log/apache2/access.log" ] #Ubuntu
    #path => [ "/var/log/httpd/access_log" ] #CentOS,RHEL
  }
  file {
    type => "apache-error"
    path => [ "/var/log/httpd/error_log", "/var/log/apache2/error.log" ]
    #path => [ "/var/log/apache2/error.log" ] #Ubuntu
    #path => [ "/var/log/httpd/error_log" ] #CentOS,RHEL
  }
  #file {
  #  type => "apache-json"
  #  path => [ "/var/log/httpd/access_json.log" ]
  #}
}
filter {
  grok {
    type => "linux-syslog"       #type "syslog"
    pattern => "%{SYSLOGLINE}"
  }
  # multiline{
    # type => "xyz-stdout-log"
    # pattern => "^\s"
    # what => previous
  # }
}
output {
  stdout {
    #only for mode DEBUG
    debug => true
    debug_format => "json"
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
    # THE IP ADDRESS FOR YOUR SERVER CENTRALIZED!!!
    host => "192.168.17.89" # SERVER CENTRALIZED REDIS
    data_type => "list"
    key => "logstash-redis"
  }
}
ZEOF
[ -d "/etc/logstash/test" ] && sudo cp distributed-logstash-shipper2redis.conf /etc/logstash/test/shipper2redis.conf;
echo "DON'T FORGET TO CHANGE the IP ADDRESS from YOUR SERVER CENTRALIZED !!! into '/etc/logstash/test/shipper2redis.conf' "
EOF
chmod a+x distributed-logstash.putconf.sh

cat <<EOF >distributed-logstash.sh
#!/bin/sh
/etc/init.d/logstash restart
EOF
chmod a+x distributed-logstash.sh

cat <<"EOF" >distributed-logstash.test.sh
#!/bin/sh

yourIP=$(hostname -I | cut -d' ' -f1);
echo "TESTS : STDIN LOGSTASH local : Just wait 60s before to tape a new message !!! CTRL-C to <exit>";
echo 'java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -e "input{}";'
echo 'java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -e "input{}" -l /var/log/logstash/logstash.log ;'
echo 'java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -f /etc/logstash/test/stdin2stdout.conf -l /var/log/logstash/logstash.log ;'
echo 'java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -f /etc/logstash/test/shipper2redis.conf -l /var/log/logstash/logstash.log ;'
echo "DON'T FORGET TO CHANGE the IP ADDRESS from YOUR SERVER CENTRALIZED !!! into '/etc/logstash/test/shipper2redis.conf' "
EOF
chmod a+x distributed-logstash.test.sh


cat <<"EOF" >etc-init.d-ulogstash
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
# Update: ardoise.gisement@gmail.com, modified by https://github.com/ardoise
 
### END INIT INFO
 
# Amount of memory for Java
JAVAMEM=256M
 
# Location of logstash files
LOCATION=/opt/logstash
 
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
DESC="Logstash Daemon"
NAME=java
DAEMON=`which java`
CONFIG_DIR="/etc/logstash/"
LOGFILE="/var/log/logstash/logstash.log"
PATTERNSPATH="/opt/logstash/patterns"
JARNAME=logstash-1.1.12-flatjar.jar;
JARNAME=logstash-1.1.13-flatjar.jar;
# --grok-patterns-path flag is deprecated
# patterns_dir: ${PATTERNSPATH}
ARGS="-Xmx$JAVAMEM -Xms$JAVAMEM -jar $LOCATION/${JARNAME} agent --config ${CONFIG_DIR} -vv --log ${LOGFILE}" ; # level=debug
ARGS="-Xmx$JAVAMEM -Xms$JAVAMEM -jar $LOCATION/${JARNAME} agent --config ${CONFIG_DIR} -v --log ${LOGFILE}" ; # level=info
ARGS="-Xmx$JAVAMEM -Xms$JAVAMEM -jar $LOCATION/${JARNAME} agent --config ${CONFIG_DIR} --log ${LOGFILE}" ; # level=warn

SCRIPTNAME=/etc/init.d/logstash
base=logstash

pid=`ps auxww | grep 'logstash-.*flatjar' | grep java | awk '{print $2}'`
# pid="/var/run/$name.pid"
   
# Exit if the package is not installed
if [ ! -x "$DAEMON" ]; then
{
  echo "Couldn't find $DAEMON"
  exit 99
}
fi

# Check if $pid (could be plural) are running
checkpid() {
  local i;
  for i in $* ; do
    [ -d "/proc/$i" ] && return 0
  done
  return 1
}

[ -e "/etc/rc.d/init.d/functions" ] && . /etc/rc.d/init.d/functions 
[ -e "/etc/init.d/functions" ] && . /etc/init.d/functions
[ -e "/lib/lsb/init-functions" ] && . /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
  if checkpid $pid; then
    success
  else
    cd $LOCATION && ($DAEMON $ARGS &) && success || failure
  fi
}
 
#
# Function that stops the daemon/service
#
do_stop()
{
  if checkpid $pid; then
    sudo kill -9 $pid
  fi
}
 
case "$1" in
start)
  echo -n "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Starting $DESC: "
  do_start
;;
stop)
  echo -n "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Stopping $DESC: "
  do_stop
;;
restart|reload)
  echo -n "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Restarting $DESC: "
  do_stop
  do_start
;;
status)
  status -p $pid
;;
*)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Usage: $SCRIPTNAME {start|stop|status|restart}" >&2
  exit 3
;;
esac
 
echo
exit 0
EOF
chmod 755 etc-init.d-ulogstash ;
sudo cp etc-init.d-ulogstash /etc/init.d/logstash ; # ubuntu

cat <<"EOF" >etc-init.d-clogstash
#! /bin/sh
 
### BEGIN INIT INFO
# Provides: logstash
# Required-Start: $remote_fs $syslog
# Required-Stop: $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start Logstash as a daemon
# Desc : user the LSB scripting
# Update: ardoise.gisement@gmail.com, modified by https://github.com/Ardoise/KataScript
### END INIT INFO

DAEMON=`which java`

# Exit if the package is not installed
if [ ! -x "$DAEMON" ]; then
{
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Couldn't find $DAEMON"
  exit 99
}
fi

[ -f "/lib/lsb/init-functions" ] && . /lib/lsb/init-functions
[ -f "/etc/init.d/functions" ] && . /etc/init.d/functions
[ -f "/etc/rc.d/init.d/functions" ] && . /etc/rc.d/init.d/functions

name="logstash"
JAVAMEM=256M
JARNAME=logstash-1.1.13-flatjar.jar
PATTERNSPATH="/opt/$name/patterns"
JAR_BIN="$DAEMON -- -jar /opt/$name/$JARNAME"
ETC_DIR="/etc/$name/"
LOGFILE="/var/log/$name/$name.log"
pid="/var/run/$name.pid"
NICE_LEVEL="-n 19"
ARGS="-Xmx$JAVAMEM -Xms$JAVAMEM"

start () {
  command="/usr/bin/nice ${NICE_LEVEL} ${JAR_BIN} agent -f ${ETC_DIR} -vv --log ${LOGFILE} --patterns_dir ${PATTERNSPATH}"
   
  log_daemon_msg "Starting" "$name"
  if start-stop-daemon --start --quiet --oknodo --pidfile "$pid" -b -m --exec $command; then
  log_end_msg 0
  else
  log_end_msg 1
  fi
}
 
stop () {
  start-stop-daemon --stop --quiet --oknodo --pidfile "$pid"
}
 
status () {
  status_of_proc -p $pid "" "$name"
}
 
case $1 in
  start)
    # echo -n "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Starting $DESC: "
    if status; then exit 0; fi
    start
  ;;
  stop)
    # echo -n "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Stopping $DESC: "
    stop
    sudo rm -f $pid
  ;;
  reload)
    # echo -n "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Reloading $DESC: "
    # pkill -HUP -u $LOGSTASH_USER
    stop
    start
  ;;
  restart)
    # echo -n "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Restarting $DESC: "
    stop
    start
  ;;
  status)
    status && exit 0 || exit $?
  ;;
  *)
    echo "Usage: $0 {start|stop|restart|reload|status}"
    exit 1
  ;;
esac

exit 0
EOF
chmod 755 etc-init.d-clogstash ;
# sudo cp etc-init.d-clogstash /etc/init.d/logstash ; # centOS

# REST : CHILD
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: distributed-logstash : get binaries ..."
sh distributed-logstash.getbin.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: distributed-logstash : get binaries [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: distributed-logstash : put config ..."
sh distributed-logstash.putconf.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: distributed-logstash : put config [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: distributed-logstash : start service ..."
sh distributed-logstash.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: distributed-logstash : start service [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: distributed-logstash : test service ..."
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: don't forget to test your service : /opt/centrallog/distributed-logstash.test.sh";
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: distributed-logstash : test service [ OK ]"

exit 0;
