#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: jboss
# Short-Description: DEPLOY SERVER: [JBOSS]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130714
### END INIT INFO

# Description: SERVICE CENTRALLOG: jboss (...)
# - deploy jboss v7.1.1
#
# Requires : you need root privileges tu run this script
# Requires : curl wget make build-essential zlib1g-dev libssl-dev git-core
#
# CONFIG:   [ "/etc/jboss", "/etc/jboss/test" ]
# BINARIES: [ "/opt/jboss/", "/usr/share/jboss/" ]
# LOG:      [ "/var/log/jboss/" ]
# RUN:      [ "/var/run/jboss/" ]
# INIT:     [ "/etc/init.d/jboss" ]

DESCRIPTION="JBOSS Server";
NAME="jboss";

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

# OWNER
[ -e "${SH_DIR}/lib/usergroup.sh" ] && . ${SH_DIR}/lib/usergroup.sh || exit 1;
uid=$NAME;gid=$NAME;group=devops;pass=$NAME;
usergroup POST;

sudo mkdir -p /opt/$NAME || true; sudo chown -R $uid:$gid /opt/$NAME || true
sudo mkdir -p /etc/$NAME/test || true; sudo chown -R $uid:$gid /etc/$NAME || true
sudo mkdir -p /var/lib/$NAME || true; sudo chown -R $uid:$gid /var/lib/$NAME || true
sudo mkdir -p /var/log/$NAME || true; sudo chown -R $uid:$gid /var/log/$NAME || true
sudo mkdir -p /var/run/$NAME || true; sudo chown -R $uid:$gid /var/run/$NAME || true

# Install packages necessary to compile Ruby from source
case "$platform" in
  Debian)
    sudo apt-get update #--fix-missing
    apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline5-dev make curl git-core;
    ;;
  Ubuntu)
    sudo apt-get update #--fix-missing
    apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline-dev make curl git-core;
    ;;
esac

git clone http://github.com/Ardoise/KataScript;
git pull;
cd KataScript/sh/centrallog;


echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-$NAME : get binaries ..."
sh centralized-$NAME.getbin.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-$NAME : get binaries [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-$NAME : put config ..."
sh centralized-$NAME.putconf.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-$NAME : put config [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-$NAME : start ..."
sh centralized-$NAME.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-$NAME : start [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-$NAME : test ..."
sh centralized-$NAME.test.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-$NAME : test [ OK ]"

exit $SCRIPT_OK
