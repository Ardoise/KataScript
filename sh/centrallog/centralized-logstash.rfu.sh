#!/bin/sh
### BEGIN INIT INFO
# Provides: centrallog: logstash
# Short-Description: DEPLOY SERVER: [BROKER, INDEXER, STORAGESEARCH, WEBUI]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130531
### END INIT INFO

# Description: SERVICE CENTRALLOG: LOGSTASH (shipper)
# - deploy logstash v1.1.13
#
# Requires : you need root privileges tu run this script
# Requires : JRE7 to run logstash
# Requires : curl
#
# CONFIG: [ "/etc/logstash", "/etc/logstash/test" ]
#   CAS0: logstash => logstash       (test stdin         => stdout)
#   CAS1: logstash => elasticsearch  (test local shipper => elasticsearch)
#   CAS2: logstash => redis          (test local shipper => redis)
#   CAS3: redis    => elasticsearch  (test local redis   => elasticsearch)
# BINARIES: [ "/opt/logstash/" ]
# LOG:      [ "/var/log/logstash/" ]
# RUN:      [ "/var/run/logstash.pid" ]
# INIT:     [ "/etc/init.d/logstash" ]

set -e

NAME=logstash
DESC="logstash Server"
DEFAULT=/etc/default/$NAME

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

# TODO : USE IT !
[ -e "/lib/lsb/init-functions" ] && . /lib/lsb/init-functions
[ -r /etc/default/rcS ] && . /etc/default/rcS
. ./stdlevel; # DEPRECATED

cat <<EOF >centralized-logstash.getbin.sh
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
chmod a+x centralized-logstash.getbin.sh

# SERVICE CENTRALLOG
# CAS0 : logstash => logstash       (test stdin         => stdout)
# CAS1 : logstash => elasticsearch  (test local shipper => elasticsearch)
# CAS2 : logstash => redis          (test local shipper => redis)
# CAS3 : redis    => elasticsearch  (test local redis   => elasticsearch)
cat <<"EOF" >centralized-logstash.putconf.sh
#!/bin/sh

yourIP=$(hostname -I | cut -d' ' -f1);

[ -d "/etc/logstash/test" ] || sudo mkdir -p /etc/logstash/test;
cat <<ZEOF >centralized-logstash-stdin2stdout.conf
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
[ -d "/etc/logstash/test" ] && sudo cp centralized-logstash-stdin2stdout.conf /etc/logstash/test/stdin2stdout.conf;


[ -d "/etc/logstash/test" ] || sudo mkdir -p /etc/logstash/test;
cat <<ZEOF >centralized-logstash-stdin2elasticsearch.conf
input {
  stdin {
    charset => "UTF-8"      # "ISO8859-1"... "locale", "external", "filesystem", "internal"
    debug => true
    type => "stdin"         # string (required)
  }
}
output {
  stdout {
    debug => true
    debug_format => "json"
    type => "stdout"
  }
  elasticsearch {
    embedded => false                #another process elasticsearch
    host => "${yourIP:=127.0.0.1}"   #see elasticsearch.yml
    cluster => "centrallog"          #see elasticsearch.yml
  }  
}
ZEOF
[ -d "/etc/logstash/test" ] && sudo cp centralized-logstash-stdin2elasticsearch.conf /etc/logstash/test/stdin2elasticsearch.conf;


[ -d "/etc/logstash/test" ] || sudo mkdir -p /etc/logstash/test;
cat <<ZEOF >centralized-logstash-shipper2elasticsearch.conf
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
}
filter {
  grok {
    type => "linux-syslog"        # for logs of type "syslog"
    pattern => "%{SYSLOGLINE}"
    # You can specify multiple 'pattern' lines
  }
}
output {
  stdout {
    #only for mode DEBUG
    debug => true
    debug_format => "json"
  }
  elasticsearch {
    embedded => false                #another process elasticsearch
    host => "${yourIP:=127.0.0.1}"   #see elasticsearch.yml
    cluster => "centrallog"          #see elasticsearch.yml
  }
}
ZEOF
[ -d "/etc/logstash/test" ] && sudo cp centralized-logstash-shipper2elasticsearch.conf /etc/logstash/test/shipper2elasticsearch.conf;


[ -d "/etc/logstash/test" ] || sudo mkdir -p /etc/logstash/test;
cat <<ZEOF >centralized-logstash-shipper2redis.conf
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
    host => "${yourIP:=127.0.0.1}" 
    data_type => "list"
    key => "logstash-redis"
  }
}
ZEOF
[ -d "/etc/logstash/test" ] && sudo cp centralized-logstash-shipper2redis.conf /etc/logstash/test/shipper2redis.conf;


[ -d "/etc/logstash/test" ] || sudo mkdir -p /etc/logstash/test;
cat <<ZEOF >centralized-logstash-redis2elasticsearch.conf
input {
  redis {
    # add_field => ... # hash (optional), default: {}
    # batch_count => ... # number (optional), default: 1
    # charset => ... # string, one of ["ASCII-8BIT", "UTF-8", "US-ASCII", "Big5", "Big5-HKSCS", "Big5-UAO", "CP949", "Emacs-Mule", "EUC-JP", "EUC-KR", "EUC-TW", "GB18030", "GBK", "ISO-8859-1", "ISO-8859-2", "ISO-8859-3", "ISO-8859-4", "ISO-8859-5", "ISO-8859-6", "ISO-8859-7", "ISO-8859-8", "ISO-8859-9", "ISO-8859-10", "ISO-8859-11", "ISO-8859-13", "ISO-8859-14", "ISO-8859-15", "ISO-8859-16", "KOI8-R", "KOI8-U", "Shift_JIS", "UTF-16BE", "UTF-16LE", "UTF-32BE", "UTF-32LE", "Windows-1251", "BINARY", "IBM437", "CP437", "IBM737", "CP737", "IBM775", "CP775", "CP850", "IBM850", "IBM852", "CP852", "IBM855", "CP855", "IBM857", "CP857", "IBM860", "CP860", "IBM861", "CP861", "IBM862", "CP862", "IBM863", "CP863", "IBM864", "CP864", "IBM865", "CP865", "IBM866", "CP866", "IBM869", "CP869", "Windows-1258", "CP1258", "GB1988", "macCentEuro", "macCroatian", "macCyrillic", "macGreek", "macIceland", "macRoman", "macRomania", "macThai", "macTurkish", "macUkraine", "CP950", "Big5-HKSCS:2008", "CP951", "stateless-ISO-2022-JP", "eucJP", "eucJP-ms", "euc-jp-ms", "CP51932", "eucKR", "eucTW", "GB2312", "EUC-CN", "eucCN", "GB12345", "CP936", "ISO-2022-JP", "ISO2022-JP", "ISO-2022-JP-2", "ISO2022-JP2", "CP50220", "CP50221", "ISO8859-1", "Windows-1252", "CP1252", "ISO8859-2", "Windows-1250", "CP1250", "ISO8859-3", "ISO8859-4", "ISO8859-5", "ISO8859-6", "Windows-1256", "CP1256", "ISO8859-7", "Windows-1253", "CP1253", "ISO8859-8", "Windows-1255", "CP1255", "ISO8859-9", "Windows-1254", "CP1254", "ISO8859-10", "ISO8859-11", "TIS-620", "Windows-874", "CP874", "ISO8859-13", "Windows-1257", "CP1257", "ISO8859-14", "ISO8859-15", "ISO8859-16", "CP878", "Windows-31J", "CP932", "csWindows31J", "SJIS", "PCK", "MacJapanese", "MacJapan", "ASCII", "ANSI_X3.4-1968", "646", "UTF-7", "CP65000", "CP65001", "UTF8-MAC", "UTF-8-MAC", "UTF-8-HFS", "UTF-16", "UTF-32", "UCS-2BE", "UCS-4BE", "UCS-4LE", "CP1251", "UTF8-DoCoMo", "SJIS-DoCoMo", "UTF8-KDDI", "SJIS-KDDI", "ISO-2022-JP-KDDI", "stateless-ISO-2022-JP-KDDI", "UTF8-SoftBank", "SJIS-SoftBank", "locale", "external", "filesystem", "internal"] (optional), default: "UTF-8"
    # data_type => ... # string, one of ["list", "channel", "pattern_channel"] (optional)
    # db => ... # number (optional), default: 0
    # debug => ... # boolean (optional), default: false
    # format => ... # string, one of ["plain", "json", "json_event", "msgpack_event"] (optional)
    #              Value can be any of: "plain", "json", "json_event", "msgpack_event"
    #              There is no default value for this setting.
    #              The format of input data (plain, json, json_event)
    # host => ... # string (optional), default: "127.0.0.1"
    # key => ... # string (optional) The name of a redis list or channel
    # message_format => ... # string (optional)
    #               If format is "json_event", ALL fields except for @type are expected to be present. 
    #               Not receiving all fields will cause unexpected results.
    # password => ... # password (optional)
    # port => ... # number (optional), default: 6379
    # tags => ... # array (optional)
    # threads => ... # number (optional), default: 1
    # timeout => ... # number (optional), default: 5
    # type => ... # string (required)
    
    host => "${yourIP:=127.0.0.1}" 
    type => "redis-input"
    data_type => "list"
    key => "logstash-redis"
    # format => "plain"
    # format => "json"
    format => "json_event" 
  }
}
output {
  stdout { 
    #only for mode DEBUG
    debug => true
    debug_format => "json"
  }
  elasticsearch {
    # bind_host => ... # string (optional)
    # cluster => ... # string (optional)
    # document_id => ... # string (optional), default: nil
    # embedded => ... # boolean (optional), default: false
    # embedded_http_port => ... # string (optional), default: "9200-9300"
    # exclude_tags => ... # array (optional), default: []
    # fields => ... # array (optional), default: []
    # host => ... # string (optional)
    # index => ... # string (optional), default: "logstash-%{+YYYY.MM.dd}"
    # index_type => ... # string (optional), default: "%{@type}"
    # max_inflight_requests => ... # number (optional), default: 50
    # node_name => ... # string (optional)
    # port => ... # number (optional), default: "9300-9400"
    # tags => ... # array (optional), default: []
    # type => ... # string (optional), default: ""
    
    embedded => false                 #another process elasticsearch
    host => "${yourIP:=127.0.0.1}"    #see elasticsearch.yml
    cluster => "centrallog"           #see elasticsearch.yml
  }
}
ZEOF
[ -d "/etc/logstash/test" ] && sudo cp centralized-logstash-redis2elasticsearch.conf /etc/logstash/test/redis2elasticsearch.conf;

EOF
chmod a+x centralized-logstash.putconf.sh

cat <<EOF >centralized-logstash.sh
#!/bin/sh
# -Des.path.data="/var/lib/elasticsearch/"
# logstash-1.1.9-monolithic.jar
# OLD CALLs
# nohup java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -v -f /etc/logstash/shipper2elasticsearch.conf -l /var/log/logstash/shipper.log 2>&1&
# nohup java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -v -f /etc/logstash/shipper2redis.conf -l /var/log/logstash/redis.log 2>&1&
# nohup java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -v -f /etc/logstash/redis2elasticsearch.conf -l /var/log/logstash/elasticsearch.log 2>&1&

/etc/init.d/logstash restart
EOF
chmod a+x centralized-logstash.sh

cat <<"EOF" >centralized-logstash.test.sh
#!/bin/sh

yourIP=$(hostname -I | cut -d' ' -f1);
echo "TESTS : STDIN LOGSTASH local : Just wait 60s before to tape a new message !!! CTRL-C to <exit>";
echo 'java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -e "input{}";'
echo 'java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -e "input{}" -l /var/log/logstash/logstash.log ;'
echo 'java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -f /etc/logstash/test/stdin2stdout.conf -l /var/log/logstash/logstash.log ;'
echo 'java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -f /etc/logstash/test/stdin2elasticsearch.conf -l /var/log/logstash/logstash.log ;'
echo 'java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -f /etc/logstash/test/stdin2redis.conf -l /var/log/logstash/logstash.log ;'
echo 'java -jar /opt/logstash/logstash-1.1.13-flatjar.jar agent -f /etc/logstash/test/shipper2elasticsearch.conf -l /var/log/logstash/logstash.log ;'

# echo "TEST daemon logstash ELASTICSEARCH : ";
# echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: curl -XGET http://${yourIP:=127.0.0.1}:9200/_status?pretty=true"
# echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: curl -XGET http://${yourIP:=127.0.0.1}:9200/logstash-$(date +'%Y.%m.%d')/_status?pretty=true"
EOF
chmod a+x centralized-logstash.test.sh


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
#  # pid=`ps auxww | grep 'logstash.*monolithic' | grep java | awk '{print $2}'`
#  if checkpid $pid 2>&1; then
#    # TERM first, then KILL if not dead
#    kill -TERM $pid >/dev/null 2>&1
#    usleep 100000
#    if checkpid $pid && sleep 1 &&
#        checkpid $pid && sleep $delay &&
#        checkpid $pid ; then
#        kill -KILL $pid >/dev/null 2>&1
#        usleep 100000
#    fi
#  fi
#  checkpid $pid
#  RC=$?
#  [ "$RC" -eq 0 ] && failure $"$base shutdown" || success $"$base shutdown" 

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
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-logstash : get binaries ..."
sh centralized-logstash.getbin.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-logstash : get binaries [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-logstash : put config ..."
sh centralized-logstash.putconf.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-logstash : put config [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-logstash : start service ..."
sh centralized-logstash.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-logstash : start service [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-logstash : test service ..."
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: don't forget to test your service : /opt/centrallog/centralized-logstash.test.sh";
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-logstash : test service [ OK ]"

exit 0;