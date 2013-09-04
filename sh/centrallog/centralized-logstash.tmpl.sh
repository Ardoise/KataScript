#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: logstash
# Short-Description: DEPLOY SERVER: [LOGSTASH]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130727
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
yourIP=$(hostname -I | cut -d' ' -f1);
JSON=json/cloud.json

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit $SCRIPT_ERROR
fi

case "$1" in
check)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  #i#check#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
config|reload)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
PATTERN_FILE=https://raw.github.com/Ardoise/KataScript/master/sh/etc/logstash/redis2elasticsearch
CONF_FILE=/etc/logstash/redis2elasticsearch.conf
  [ ! -z "${CONF_FILE}" -a ! -z "${PATTERN_FILE}" ] && (
    curl -L ${PATTERN_FILE} -o ${CONF_FILE};
    # CONTEXT VALUES LOCAL
    uidgid=`${SH_DIR}/lib/usergroup.sh GET uid=$NAME form=ug`;
    chown -R $uidgid ${CONF_FILE};
  )
  
    # echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: test /etc/init.d/$NAME";
  # [ -s "/etc/init.d/$NAME" ] || (
    # cd /etc/init.d;
    # sudo curl -L  "https://raw.github.com/Ardoise/KataScript/master/sh/etc/init.d/ulogstash" -o /etc/init.d/$NAME;
    # sudo chmod a+x /etc/init.d/$NAME;
  # )

  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
install)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  
  # DEPENDS : PLATFORM
  case "$platform" in
  Debian)
    apt-get update #--fix-missing #--no-install-recommends
    apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline5-dev make curl git-core openjdk-6-jre-headless || return $?;
    ;;
  Ubuntu)
    apt-get update #--fix-missing
    apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline-dev make curl git-core openjdk-6-jre-headless || return $?;
    ;;
  Redhat|Fedora|CentOS)
    yum update #--fix-missing
    yum -y install make curl git-core || return $?;
    echo "NOT YET TESTED : your contribution is welc0me"
    ;;
  esac

  # CENTRALLOG : PROFIL
  Bin="/opt/";echo "$Bin";
  Cache="/var/cache/"; echo "$Cache";
  Etc="/etc/";echo "$Etc";
  Lib="/var/lib/";echo "$Lib";
  Log="/var/log/";echo "$Log";
  Run="Run";echo "$Run";
  
  # DEPENDS : OWNER
  [ -e "${SH_DIR}/lib/usergroup.sh" ] || exit 1;
  ${SH_DIR}/lib/usergroup.sh POST uid=$NAME gid=$NAME group=devops pass=$NAME;
  ${SH_DIR}/lib/usergroup.sh OPTION uid=$NAME;
  echo "PATH=\$PATH:/opt/$NAME" >/etc/profile.d/centrallog_$NAME.sh;
  uidgid=`${SH_DIR}/lib/usergroup.sh GET uid=$NAME form=ug`;
  
  # DEPENDS : PROFIL, OWNER
  mkdir -p $Bin$NAME || true; chown -R $uidgid $Bin$NAME || true;
  mkdir -p $Cache$NAME || true; chown -R $uidgid $Cache$NAME || true;
  mkdir -p $Etc$NAME/test || true; chown -R $uidgid $Etc$NAME || true;
  mkdir -p $Lib$NAME || true; chown -R $uidgid $Lib/$NAME || true;
  mkdir -p $Log$NAME || true; chown -R $uidgid $Log/$NAME || true;
  mkdir -p $Run$NAME || true; chown -R $uidgid $Run/$NAME || true;

  # DEPENDS : DOWNLOAD CACHE, INSTALL
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: test $Cache$NAME/$file";
  Download="https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jarnull";
  file=$(basename $Download);
  cd $Bin$Name;
  case "$file" in
    *.tar.gz|*.tgz)
      [ -s "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL  "https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jarnull");
      [ -s "$Cache$NAME/$file" ] && sudo tar -xvfz $Cache$NAME/$file;
      cat <<-REOF >$Bin$Name/$Name.uninstall
      rm -rf $Bin$Name/*.*;
REOF
    ;;
    *.rpm)
      [ -s "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL  "https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jarnull");
      [ -s "$Cache$NAME/$file" ] && sudo rpm -ivh $Cache$NAME/$file;
      cat <<-REOF >$Bin$Name/$Name.uninstall
      # TODO
      #rpm -qa | grep $NAME
      #rpm -e $NAME;
      [ -d "$Bin$NAME" ] && rm -rf $Bin$NAME;
REOF
    ;;
    *.deb)
      [ -s "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL  "https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jarnull");
      [ -s "$Cache$NAME/$file" ] && sudo dpkg -i $Cache$NAME/$file;
      cat <<-REOF >$Bin$Name/$Name.uninstall
      # TODO
      #dpkg -l |grep "$NAME"
      #dpkg -P "$NAME"
      #dpkg --uninstall $NAME
REOF
    ;;
    *.zip)
      [ -s "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL  "https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jarnull");
      [ -s "$Cache$NAME/$file" ] && sudo unzip $Cache$NAME/$file;
      cat <<-REOF >$Bin$Name/$Name.uninstall
REOF
    ;;
    *.jar)
      [ -s "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL  "https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jarnull");
      [ -s "$Cache$NAME/$file" ] && sudo cp -R $Cache$NAME/$file $Bin$NAME/;
      cat <<-REOF >$Bin$Name/$Name.uninstall
REOF
    ;;
    *)
      case "$platform" in
      Debian|Ubuntu)
        apt-get update #--fix-missing
        apt-get -y install $NAME;
        cat <<-REOF >$Bin$Name/$Name.uninstall
        apt-get uninstall $NAME;
REOF
        ;;
      Redhat|Fedora|CentOS)
        yum update #--fix-missing
        yum -y install $NAME;
        cat <<-REOF >$Bin$Name/$Name.uninstall
        yum uninstall $NAME;
REOF
        ;;
      esac
    ;;
  esac
  cat <<-REOF >>$Bin$Name/$Name.uninstall
    pkill -u $uidgid;
    [ -f "$Cache$NAME" ] && rm -rf "$Cache$NAME";
    [ -d "$Bin$NAME" ] && rm -rf "$Bin$NAME";
    [ -d "$Log$NAME" ] && rm -rf "$Log$NAME";
    [ -d "$Lib$NAME" ] && rm -rf "$Lib$NAME";
    [ -d "$Run$NAME" ] && rm -rf "$Run$NAME";
    [ -d "$Etc$NAME" ] && rm -rf "$Etc$NAME";
REOF
  chown -R $uidgid $Bin$NAME || true;
  
  #i#install#i#
  
  chown -R $uidgid /opt/$NAME;
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
uninstall)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  [ -s "$Bin$Name/$Name.uninstall" ] && cp $Bin$Name/$Name.uninstall /tmp/$Name.uninstall;
  [ -s "/tmp/$Name.uninstall" ] && sh -x /tmp/$Name.uninstall;
  #i#uninstall#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
start)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  # [ -x "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME start && exit 0 || exit $?);
/etc/init.d/logstash start
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
stop)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  # [ -s "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME stop && exit 0 || exit $?);
/etc/init.d/logstash stop
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
status)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  # [ -s "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME status && exit 0 || exit $?);
/etc/init.d/logstash status
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
upgrade)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  #i#upgrade#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
dist-upgrade)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  
  echo "#FOR USE HTTP-PROXY"
  echo "export http_proxy='http://proxy.hostname.com:port'"
  echo "export https_proxy='https://proxy.hostname.com:port'"
  
  echo "#INSTALL RVM 1.22.3 with ruby 2.0.0-p247"
  curl -L https://get.rvm.io | bash -s stable --ruby
  
  echo "#INSTALL RVM 1.22.3 with jruby 1.7.4 and Rubies gems"
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
    check   - check centrallog::logstash
    install - install centrallog::logstash
    reload  - reload config centrallog::logstash
    uninstall  - uninstall centrallog::logstash
    start   - start centrallog::logstash
    status  - status centrallog::logstash
    stop    - stop centrallog::logstash
    upgrade - upgrade centrallog::logstash
    dist-upgrade - upgrade platform with jruby::gems
_EOF_
;;
esac

unset uid gid group pass;

exit $SCRIPT_OK
