#!/bin/sh
### BEGIN INIT INFO
# Provides: JRE, JDK
# Short-Description: JAVA SERVER:
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130608
### END INIT INFO

# Description: SERVICE JAVE
# - use jre7
# - use jdk7
#
# Requires : you need root privileges tu run this script
# Requires : curl
#
# CONFIG:   [ "" ]
# BINARIES: [ "/opt/java/" ]
# LOG:      [ "" ]
# RUN:      [ "" ]
# INIT:     [ "" ]
# PLUGINS:  [ "" ]

set -e

NAME=java
DESC="Java Server"
DEFAULT=/etc/default/$NAME

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

[ -d "/opt/java" ] || sudo mkdir -p /opt/java;

cat <<EOF >standalone-openjdk7jre.getbin.sh
#!/bin/sh

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

case $DISTRIB in
*ubuntu*)
  cd ~;
  sudo apt-get update;
  sudo apt-get install openjdk-7-jre-headless -y;
;;
Red*hat*|*redhat*)
  echo "Sorry ! for your OS $SYSTEM $DISTRIB, your contribution is WelcOme ! ardoise.gisement@gmail.com";
;;
*)
  echo "Sorry ! for your OS $SYSTEM $DISTRIB, your contribution is WelcOme ! ardoise.gisement@gmail.com";
;;
EOF


cat <<EOF >standalone-orajdk7.getbin.sh
#!/bin/sh

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

case $DISTRIB in
*ubuntu*)
  cd ~;
  sudo add-apt-repository ppa:webupd8team/java
  sudo apt-get update
  sudo apt-get install oracle-java7-installer
;;
Red*hat*|*redhat*)
  echo "Sorry ! for your OS $SYSTEM $DISTRIB, your contribution is WelcOme ! ardoise.gisement@gmail.com";
;;
*)
  echo "Sorry ! for your OS $SYSTEM $DISTRIB, your contribution is WelcOme ! ardoise.gisement@gmail.com";
;;
EOF

