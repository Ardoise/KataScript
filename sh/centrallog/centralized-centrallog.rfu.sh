#!/bin/sh
### BEGIN INIT INFO
# Provides: centrallog
# Short-Description: DEPLOY SERVER: [BROKER, INDEXER, STORAGESEARCH, WEBUI]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130531
### END INIT INFO

# Description:
# - deploy logstash v1.1.13
# - deploy redis v2.6.11
# - deploy elasticsearch v0.90.0
# - deploy kibana3
#
# Requires : /opt/centrallog is necessary to deploy the packages
# Requires : you need root privileges tu run the children's scripts

set -e

# TODO : USE IT !
[ -e "/lib/lsb/init-functions" ] && . /lib/lsb/init-functions
[ -r /etc/default/rcS ] && . /etc/default/rcS

# is Necessary ?
if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

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
  [ -s "./centralized-mongodb.rfu.sh" ] && (
    read -p "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Do you wish install centralized-mongodb (y/n)? :" key
    case $key in
      "Y" | "y")  ./centralized-mongodb.rfu.sh; ;;
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
