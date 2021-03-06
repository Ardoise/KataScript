#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: graylog
# Short-Description: DEPLOY SERVER: [GRAYLOG2]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130721
### END INIT INFO

# Description: SERVICE CENTRALLOG: graylog (...)
# - deploy graylog v0.0.0
#
# Requires : you need root privileges tu run this script
# Requires : curl wget make build-essential zlib1g-dev libssl-dev git-core
# Depends  : lib/usergroup.sh
#
# CONFIG:   [ "/etc/graylog", "/etc/graylog/test" ]
# BINARIES: [ "/opt/graylog/", "/usr/share/graylog/" ]
# LOG:      [ "/var/log/graylog/" ]
# RUN:      [ "/var/run/graylog/" ]
# INIT:     [ "/etc/init.d/graylog" ]

# @License

DESCRIPTION="GRAYLOG2 Server";
NAME="graylog";

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
  
  # DEPENDS : PLATFORM
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
  Redhat|Fedora|CentOS)
    yum update #--fix-missing
    yum -y install make curl git-core;
    echo "NOT YET TESTED : your contribution is welc0me"
    ;;
  esac

  # DEPENDS : OWNER
  [ -e "${SH_DIR}/lib/usergroup.sh" ] || exit 1;
  ${SH_DIR}/lib/usergroup.sh POST uid=$NAME gid=$NAME group=devops pass=$NAME;
  ${SH_DIR}/lib/usergroup.sh OPTION uid=$NAME;
  echo "PATH=\$PATH:/opt/$NAME" >/etc/profile.d/centrallog_$NAME.sh;
  
  uidgid=`${SH_DIR}/lib/usergroup.sh GET uid=$NAME form=ug`;
  
  # CENTRALLOG : POINTER
  mkdir -p /opt/$NAME || true; chown -R $uidgid /opt/$NAME || true;
  mkdir -p /etc/$NAME/test || true; chown -R $uidgid /etc/$NAME || true;
  mkdir -p /var/lib/$NAME || true; chown -R $uidgid /var/lib/$NAME || true;
  mkdir -p /var/log/$NAME || true; chown -R $uidgid /var/log/$NAME || true;
  mkdir -p /var/run/$NAME || true; chown -R $uidgid /var/run/$NAME || true;

  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: test /opt/$NAME/null";
  [ -s "/opt/$NAME/null" ] || (
    cd /opt/$NAME;
    curl -OL  "nullnull";
  )

	#blabla
	#blabla
  
  chown -R $uidgid /opt/$NAME;
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
remove)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  #i#remove#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
start)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  [ -x "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME start && exit 0 || exit $?);
  #service $NAME start; #LSB
  #i#start#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
stop)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  [ -s "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME stop && exit 0 || exit $?);
  #service $NAME stop; #LSB
  #i#stop#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
status)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  [ -s "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME status && exit 0 || exit $?);
  #service $NAME status; #LSB
  #i#status#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
check)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  #i#check#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
upgrade)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  #i#upgrade#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
dist-upgrade)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  
  echo "USE HTTP-PROXY"
  echo "export http_proxy='http://proxy.hostname.com:port'"
  echo "export https_proxy='https://proxy.hostname.com:port'"
  
  echo "INSTALL RVM 1.21.9 with ruby 2.0.0-p247"
  curl -L https://get.rvm.io | bash -s stable --ruby
  echo "rvm reinstall ruby"
  
  echo "INSTALL RVM 1.21.9 with jruby 1.7.4 and Rubies gems"
  echo "curl -L https://get.rvm.io | bash -s stable --ruby=jruby \
  --gems=rails,puma,Platform,open4,POpen4,i18n,multi_json,activesupport,\
  addressable,builder,launchy,liquid,syntax,maruku,rack,sass,rack-protection,\
  tilt,sinatra,watch,yui-compressor,bonsai,hpricot,mustache,rdiscount,ronn,\
  rails,puma";
  echo "rvm install 1.9.2 ; rvm use 1.9.2 --default ; ruby -v ; which ruby"
  echo "rvm reinstall jruby,rbx"
  curl -L https://get.rvm.io | bash -s stable --ruby=jruby --gems=rails,puma
  . ~/.rvm/scripts/rvm
  rvm notes
  rvm list known
  rvm list
  # echo progress-bar >> ~/.curlrc
  
  echo "WGET JQ::JSON QUERY"
  echo "curl -OL http://stedolan.github.io/jq/download/linux64/jq"
  echo "curl -OL http://stedolan.github.io/jq/download/linux32/jq"
  curl -OL http://stedolan.github.io/jq/download/linux32/jq
  chmod a+x jq ; mv jq /usr/bin/
  
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
*)
  cat <<- _EOF_
  Commandes :
    check   - check centrallog::graylog
    install - install centrallog::graylog
    reload  - reload config centrallog::graylog
    remove  - remove centrallog::graylog
    start   - start centrallog::graylog
    status  - status centrallog::graylog
    stop    - stop centrallog::graylog
    upgrade - upgrade centrallog::graylog
    dist-upgrade - upgrade platform with jruby::gems
_EOF_
;;
esac

unset uid gid group pass;

exit $SCRIPT_OK
