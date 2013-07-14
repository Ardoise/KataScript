#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: redis
# Short-Description: DEPLOY SERVER: [REDIS]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130714
### END INIT INFO

# Description: SERVICE CENTRALLOG: redis (...)
# - deploy redis v2.6.14
#
# Requires : you need root privileges tu run this script
# Requires : curl wget make build-essential zlib1g-dev libssl-dev git-core
# Depends  : lib/usergroup.sh
#
# CONFIG:   [ "/etc/redis", "/etc/redis/test" ]
# BINARIES: [ "/opt/redis/", "/usr/share/redis/" ]
# LOG:      [ "/var/log/redis/" ]
# RUN:      [ "/var/run/redis/" ]
# INIT:     [ "/etc/init.d/redis" ]

DESCRIPTION="REDIS Server";
NAME="redis";

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

# DEPENDS : OWNER
[ -e "${SH_DIR}/lib/usergroup.sh" ] || exit 1;
${SH_DIR}/lib/usergroup.sh POST uid=$NAME gid=$NAME group=devops pass=$NAME;
echo "PATH=\$PATH:/opt/$NAME" >/etc/profile.d/centrallog_$NAME.sh

mkdir -p /opt/$NAME || true; chown -R $uid:$gid /opt/$NAME || true
mkdir -p /etc/$NAME/test || true; chown -R $uid:$gid /etc/$NAME || true
mkdir -p /var/lib/$NAME || true; chown -R $uid:$gid /var/lib/$NAME || true
mkdir -p /var/log/$NAME || true; chown -R $uid:$gid /var/log/$NAME || true
mkdir -p /var/run/$NAME || true; chown -R $uid:$gid /var/run/$NAME || true

# Install packages necessary to compile Ruby from source
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

echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : get binaries ..."
[ -s "template-$NAME.getbin.sh" ] && (
  sh template-$NAME.getbin.sh;
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : get binaries [ OK ]";
)
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : put config ...";
[ -s "template-$NAME.putconf.sh" ] && (
  sh template-$NAME.putconf.sh;
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : put config [ OK ]";
)
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : start ...";
[ -s "template-$NAME.sh" ] && (
  sh template-$NAME.sh;
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : start [ OK ]";
)
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : test ...";
[ -s "template-$NAME.test.sh" ] && (
  sh template-$NAME.test.sh;
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : test [ OK ]";
)

unset uid gid group pass;

exit $SCRIPT_OK
