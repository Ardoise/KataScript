#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: logstash
# Short-Description: DEPLOY SERVER: [LOGSTASH]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130714
### END INIT INFO

# Description: SERVICE CENTRALLOG: logstash (...)
# - deploy logstash v1.1.13
#
# Requires : you need root privileges tu run this script
# Requires : curl wget make build-essential zlib1g-dev libssl-dev git-core
# Depends  : lib/usergroup.sh
#
# CONFIG:   [ "/etc/logstash", "/etc/logstash/test" ]
# BINARIES: [ "/opt/logstash/", "/usr/share/logstash/" ]
# LOG:      [ "/var/log/logstash/" ]
# RUN:      [ "/var/run/logstash/" ]
# INIT:     [ "/etc/init.d/logstash" ]

# @License

DESCRIPTION="LOGSTASH Server";
NAME="logstash";

SCRIPT_OK=0;
SCRIPT_ERROR=1;
SCRIPT_NAME=`basename $0`; # ${0##*/}
DEFAULT=/etc/default/$NAME;
cd $(dirname $0) && SCRIPT_DIR="$PWD" && cd - >/dev/null;
SH_DIR=$(dirname $SCRIPT_DIR);
platform="$(lsb_release -i -s)";
platform_version="$(lsb_release -s -r)";

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit $SCRIPT_ERROR
fi

case "$1" in
install)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  
  # DEPENDS : OWNER
  [ -e "${SH_DIR}/lib/usergroup.sh" ] || exit 1;
  ${SH_DIR}/lib/usergroup.sh POST uid=$NAME gid=$NAME group=devops pass=$NAME;
  ${SH_DIR}/lib/usergroup.sh OPTION uid=$NAME;
  echo "PATH=\$PATH:/opt/$NAME" >/etc/profile.d/centrallog_$NAME.sh;

  mkdir -p /opt/$NAME || true; chown -R $uid:$gid /opt/$NAME || true;
  mkdir -p /etc/$NAME/test || true; chown -R $uid:$gid /etc/$NAME || true;
  mkdir -p /var/lib/$NAME || true; chown -R $uid:$gid /var/lib/$NAME || true;
  mkdir -p /var/log/$NAME || true; chown -R $uid:$gid /var/log/$NAME || true;
  mkdir -p /var/run/$NAME || true; chown -R $uid:$gid /var/run/$NAME || true;

  # Install necessary packages
  case "$platform" in
  Debian)
    apt-get update #--fix-missing
    apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline5-dev make curl git-core;
    ;;
  Ubuntu)
    apt-get update #--fix-missing
    apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline-dev make curl git-core;
    ;;
  esac
  
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
remove)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
upgrade)
  :
;;
reload)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
start|stop|status)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
check)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
*)
  cat <<- _EOF_
  Commandes :
    check   - check centrallog::component
    install - install centrallog::component
    reload  - reload config centrallog::component
    remove  - remove centrallog::component
    start   - start centrallog::component
    status  - status centrallog::component
    stop    - stop centrallog::component
    upgrade - upgrade centrallog::component
_EOF_
;;
esac

unset uid gid group pass;

exit $SCRIPT_OK
