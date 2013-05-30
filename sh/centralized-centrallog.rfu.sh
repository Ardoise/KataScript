#!/bin/sh

# RFU : READY FOR USE !
# DEPLOY CENTRALIZED SERVER : BROKER, INDEXER, STORAGESEARCH, WEBUI
# DEPLOY CENTRALIZED SERVER : SHIPPER(local), STORAGESEARCH, WEBUI
#
# created by : https://github.com/Ardoise

set -e

# TODO : USE IT !
[ -e "/lib/lsb/init-functions" ] && . /lib/lsb/init-functions
[ -r /etc/default/rcS ] && . /etc/default/rcS
# log_progress_msg "(log_progress_msg)"
# log_end_msg 0
# log_success_msg "log_success_msg"
# log_end_msg 0
# log_daemon_msg "log_daemon_msg"
# log_end_msg 0
# log_daemon_msg "log_daemon_msg"
# log_end_msg 1
# log_failure_msg "log_failure_msg"


# is Necessary ?
# if [ `id -u` -ne 0 ]; then
#  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
#  exit 1
# fi

[ -d "/opt/centrallog" ] || sudo mkdir -p /opt/centrallog;
[ -d "/opt/centrallog" ] && (
  cp stdlevel /opt/centrallog >/dev/null 2>&1
  cp -f centralized-*.rfu.sh /opt/centrallog/ >/dev/null 2>&1; 
  chmod a+x /opt/centrallog/*.sh >/dev/null 2>&1;
  cd /opt/centrallog;
  
  [ -s "./centralized-logstash.rfu.sh" ] && (
    read -p "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Do you wish install centralized-logstash (y/n)? :" key
    case $key in
      "Y" | "y")  ./centralized-logstash.rfu.sh; ;;
      *)  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Bye !"; ;;
    esac
  )
  [ -s "./centralized-redis.rfu.sh" ] && (
    read -p "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Do you wish install centralized-redis (y/n)? :" key
    case $key in
      "Y" | "y")  ./centralized-redis.rfu.sh; ;;
      *)  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Bye !"; ;;
    esac
  )
  [ -s "./centralized-elasticsearch.rfu.sh" ] && (
    read -p "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Do you wish install centralized-elasticsearch (y/n)? :" key
    case $key in
      "Y" | "y")  ./centralized-elasticsearch.rfu.sh; ;;
      *)  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Bye !"; ;;
    esac
  )
  [ -s "./centralized-kibana.rfu.sh" ] && (
    read -p "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Do you wish install centralized-kibana (y/n)? :" key
    case $key in
      "Y" | "y")  ./centralized-kibana.rfu.sh; ;;
      *)  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Bye !"; ;;
    esac
  )
)

exit 0;
