#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: xgenericx
# Short-Description: DEPLOY SERVER: [XGENERICX]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130714
### END INIT INFO

# Description: SERVICE CENTRALLOG: xgenericx (...)
# - deploy xgenericx v0.0.0
#
# Requires : you need root privileges tu run this script
# Requires : curl wget make build-essential zlib1g-dev libssl-dev git-core
#
# CONFIG:   [ "/etc/xgenericx", "/etc/xgenericx/test" ]
# BINARIES: [ "/opt/xgenericx/", "/usr/share/xgenericx/" ]
# LOG:      [ "/var/log/xgenericx/" ]
# RUN:      [ "/var/run/xgenericx/" ]
# INIT:     [ "/etc/init.d/xgenericx" ]

DESCRIPTION="XGENERICX Server";
NAME="xgenericx";

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
[ -e "${SH_DIR}/lib/usergroup.sh" ] || exit 1;
${SH_DIR}/lib/usergroup.sh POST uid=$NAME gid=$NAME group=devops pass=$NAME;

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
