#!/bin/sh

# DEPLOY CENTRALIZED SERVER : BROKER, INDEXER, SHIPPER, STORAGESEARCH, WEBUI
. ./stdlevel

cat <<EOF >centralized-logstash.getbin.sh
#
[ -d "/opt/logstash/patterns" ] || sudo mkdir -p /opt/logstash/patterns ;
[ -d "/opt/logstash/tmp" ] || sudo mkdir -p /opt/logstash/tmp ;
[ -d "/var/lib/logstash" ] || sudo mkdir -p /var/lib/logstash ;
[ -d "/var/log/logstash" ] || (
  sudo mkdir -p /var/log/logstash ;
  chmod 755 /var/log/logstash ;
)
[ -d "/etc/logstash/tmp" ] || sudo mkdir -p /etc/logstash/tmp ;
cd /opt/logstash
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
    
    host => "192.168.17.89" 
    type => "redis-input"
    data_type => "list"
    key => "logstash-redis"
    # format => "plain"
    # format => "json_event"
    format => "%{@timestamp}"
  }
}
output {
  stdout { 
    #only for mode DEBUG
    #debug => true 
    #debug_format => "json"
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
    
    embedded => false         #another process elasticsearch
    host => "192.168.17.89"   #see elasticsearch.yml
    port => "9300-9400"       #see elasticsearch.yml
    cluster => "centrallog"   #see elasticsearch.yml
  }
}
ZEOF

# SERVICE ReadyForUse
[ -d "/etc/logstash/tmp" ] || sudo mkdir -p /etc/logstash/tmp;
[ -d "/etc/logstash" ] && sudo cp centralized-logstash-shipper2elasticsearch.conf /etc/logstash/tmp/shipper2elasticsearch.conf;
[ -d "/etc/logstash" ] && sudo cp centralized-logstash-shipper2redis.conf /etc/logstash/shipper2redis.conf;
[ -d "/etc/logstash" ] && sudo cp centralized-logstash-redis2elasticsearch.conf /etc/logstash/redis2elasticsearch.conf;

EOF
chmod a+x centralized-logstash.putconf.sh

cat <<EOF >centralized-logstash.sh
#!/bin/bash
# -Des.path.data="/var/lib/elasticsearch/"
# logstash-1.1.9-monolithic.jar
# OLD CALLs
# nohup java -jar /opt/logstash/logstash-1.1.12-flatjar.jar agent -vvv -f /etc/logstash/shipper2elasticsearch.conf -l /var/log/logstash/shipper.log 2>&1&
# nohup java -jar /opt/logstash/logstash-1.1.12-flatjar.jar agent -vvv -f /etc/logstash/shipper2redis.conf -l /var/log/logstash/redis.log 2>&1&
# nohup java -jar /opt/logstash/logstash-1.1.12-flatjar.jar agent -vvv -f /etc/logstash/redis2elasticsearch.conf -l /var/log/logstash/elasticsearch.log 2>&1&

/etc/init.d/logstash restart
EOF
chmod a+x centralized-logstash.sh

cat <<EOF >centralized-logstash.test.sh
curl -XGET http://220.140.17.89:9200/_status?pretty=true
curl -XGET http://220.140.17.89:9200/logstash-2013.05.23/_status?pretty=true
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
