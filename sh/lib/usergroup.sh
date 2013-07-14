#!/bin/sh -e
### BEGIN INIT INFO
# Provides: CRUD USER GROUP 
# Short-Description: CRUD USER GROUP
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130713
### END INIT INFO

# Description: SERVICE USERGROUP with suffix 'lab-'
#
# Requires : you need root privileges tu run this script
#
# CONFIG:   [ "/etc/passwd", "/etc/group" ]
# BINARIES: [ "" ]
# LOG:      [ "" ]
# RUN:      [ "" ]
# INIT:     [ "" ]
# PLUGINS:  [ "" ]

# STATELESS
group=${group:-lab-devops};
gid=${gid:-lab-guest};
uid=${uid:-lab-guest};
pass=${pass:-lab-guest};

  : ${1?"Usage: $0 <HEAD|GET|PUT|DELETE|POST|OPTION> <uid=''> <gid=''> <group=''> <pass=''>"} # REST
  
export $@;
# env | egrep -e "uid|gid|group|pass";

case $uid in
  lab-*) : ;;
  *) uid=lab-${uid} ;;
esac
case $gid in
  lab-*) : ;;
  *) gid=lab-${gid} ;;
esac
case $group in
  lab-*) : ;;
  *) group=lab-${group} ;;
esac

# REST
case $1 in
get|GET)
  [ -z "$(id -a $uid 2>/dev/null)" ] || id -a $uid;
;;
put|post|PUT|POST)
  sudo groupadd -f -r $group;
  [ -z "$(id -g $uid 2>/dev/null)" ] && \
  sudo groupadd -r $gid;
  [ -z "$(id -u $uid 2>/dev/null)" ] && \
  sudo useradd --gid $gid --groups $group --password $pass $uid;
  sudo usermod -a -G $group $uid || true;
  [ -z "$(id -a $uid 2>/dev/null)" ] || id -a $uid;
;;
head|HEAD)
  echo "uid=65535(guest) gid=65535(guest) group[e]s=65535(guest)";
;;
delete|DELETE)
  case $uid in
    lab-*)
      [ -z "$(id -u $uid 2>/dev/null)" ] || sudo userdel $uid;
    ;;  
  esac
;;
option|OPTION)
  [ ! -z "$(id -a $uid 2>/dev/null)" ] && {
    vssh="/home/$uid/.ssh";
    mkdir -p $vssh;
    chmod 700 $vssh;
    (cd $vssh &&
    wget --no-check-certificate \
    'https://raw.github.com/Ardoise/KataScript/master/keys/id_rsa-centrallog.pub' \
    -O $vssh/authorized_keys)
    chmod 0600 $vssh/authorized_keys;
    chown -R ${uid}:${gid} $vssh;
    unset vssh;
  }
;;
*)
  :
;;
esac

exit 0
