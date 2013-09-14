#!/bin/bash -e
### BEGIN INIT INFO
# Provides: centrallog: logstash
# Short-Description: DEPLOY SERVER: [LOGSTASH]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130914
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
# CACHE:    [ "/var/cache/logstash" ]

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
init|config|reload)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
CONF_FILE=/etc/logstash/shipper2redis.conf
  [ ! -z "${CONF_FILE}" -a ! -z "${PATTERN_FILE}" ] && (
    curl -L ${PATTERN_FILE} -o ${CONF_FILE};
    # CONTEXT VALUES LOCAL
    uidgid=`${SH_DIR}/lib/usergroup.sh GET uid=$NAME form=ug`;
    chown -R $uidgid ${CONF_FILE};
  )
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
install)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";

  # LocalENV
  Bin="/opt/";echo "$Bin";
  Cache="/var/cache/"; echo "$Cache";
  Etc="/etc/";echo "$Etc";
  Lib="/var/lib/";echo "$Lib";
  Log="/var/log/";echo "$Log";
  Run="/var/run/";echo "$Run";
  
  # OWNER
  [ -e "${SH_DIR}/lib/usergroup.sh" ] || exit 1;
  ${SH_DIR}/lib/usergroup.sh POST uid=$NAME gid=$NAME group=devops pass=$NAME;
  ${SH_DIR}/lib/usergroup.sh OPTION uid=$NAME;
  echo "PATH=\$PATH:/opt/$NAME" >/etc/profile.d/profile.add.$NAME.sh;
  uidgid=`${SH_DIR}/lib/usergroup.sh GET uid=$NAME form=ug`;
  
  # LocalENV + OWNER => PROFIL
  mkdir -p $Bin$NAME || true; chown -R $uidgid $Bin$NAME || true;
  mkdir -p $Cache$NAME || true; chown -R $uidgid $Cache$NAME || true;
  mkdir -p $Etc$NAME/test || true; chown -R $uidgid $Etc$NAME || true;
  mkdir -p $Lib$NAME || true; chown -R $uidgid $Lib$NAME || true;
  mkdir -p $Log$NAME || true; chown -R $uidgid $Log$NAME || true;
  mkdir -p $Run$NAME || true; chown -R $uidgid $Run$NAME || true;

  # DOWNLOAD|CACHE + PROFIL => INSTALL => UNINSTALL
  Download="https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jar";
  file=$(basename $Download);
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: test $Cache$NAME/$file";
  cd $Bin$Name;
  case "$file" in
    *.tar.gz|*.tgz)
      [ -s "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -s "$Cache$NAME/$file" ] && sudo tar -xvfz $Cache$NAME/$file;
      cat <<-REOF >$Bin$Name/$Name.uninstall
      [ -d "$Bin$NAME" -a -n "$NAME" ] && rm -rf $Bin$Name/*.*;
REOF
    ;;
    *.rpm)
      [ -s "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -s "$Cache$NAME/$file" ] && sudo rpm -ivh $Cache$NAME/$file;
      cat <<-REOF >$Bin$Name/$Name.uninstall
      # TODO
      #rpm -qa | grep $NAME
      #rpm -e $NAME;
      [ -d "$Bin$NAME" -a -n "$NAME" ] && rm -rf $Bin$NAME;
REOF
    ;;
    *.deb)
      [ -s "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -s "$Cache$NAME/$file" ] && sudo dpkg -i $Cache$NAME/$file --root=$Bin$NAME;
      cat <<-REOF >$Bin$Name/$Name.uninstall
      # TODO
      #dpkg -l |grep "$NAME"
      #dpkg -P "$NAME"
      #dpkg --uninstall $NAME
REOF
    ;;
    *.zip)
      [ -s "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -s "$Cache$NAME/$file" ] && sudo unzip $Cache$NAME/$file -d $Bin$NAME/;
      cat <<-REOF >$Bin$Name/$Name.uninstall
      [ -d "$Bin$NAME" -a -n "$NAME" ] && rm -rf $Bin$NAME
REOF
    ;;
    *.jar)
      [ -s "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -s "$Cache$NAME/$file" ] && sudo cp -R $Cache$NAME/$file $Bin$NAME/;
      cat <<-REOF >$Bin$Name/$Name.uninstall
      [ -d "$Bin$NAME/$file" -a -n "$NAME" ] && rm -f $Bin$NAME/$file
REOF
    ;;
    *)
      case "$platform" in
      Debian|Ubuntu)
        sudo apt-get update #--fix-missing
        sudo apt-get -y install $NAME;
        cat <<-REOF >$Bin$Name/$Name.uninstall
        sudo apt-get uninstall $NAME;
REOF
        ;;
      Redhat|Fedora|CentOS)
        sudo yum update #--fix-missing
        sudo yum -y install $NAME;
        cat <<-REOF >$Bin$Name/$Name.uninstall
        sudo yum uninstall $NAME;
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

  # OWNER => POSTINSTALL
  
  #i#install#i#
  #i#postinstall#i#

  chown -R $uidgid $Bin$NAME || true;
  chown -R $uidgid $Cache$NAME || true;
  chown -R $uidgid $Etc$NAME || true;
  chown -R $uidgid $Lib$NAME || true;
  chown -R $uidgid $Log$NAME || true;
  chown -R $uidgid $Run$NAME || true;
  chown -R $uidgid $Bin$NAME || true;
    
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
restart)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  # [ -x "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME start && exit 0 || exit $?);
  CMD="#i#restart#i#";
  case $CMD in
  *i#restart#i*)
    exec $CMD && exit 0 || exit $?; 
    ;;
  *)
    service $NAME restart && exit 0 || exit $?;
    ;;
  esac
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
start)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  # [ -x "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME start && exit 0 || exit $?);
/etc/init.d/ulogstash start
  case $CMD in
  *i#start#i*)
    exec $CMD && exit 0 || exit $?; 
    ;;
  *)
    service $NAME start && exit 0 || exit $?;
    ;;
  esac
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
stop)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  # [ -s "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME stop && exit 0 || exit $?);
/etc/init.d/ulogstash start
  case $CMD in
  *i#stop#i*)
    exec $CMD && exit 0 || exit $?; 
    ;;
  *)
    service $NAME stop && exit 0 || exit $?;
    ;;
  esac
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
status)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  # [ -s "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME status && exit 0 || exit $?);
/etc/init.d/ulogstash status
  case $CMD in
  *i#start#i*)
    exec $CMD && exit 0 || exit $?; 
    ;;
  *)
    service $NAME status && exit 0 || exit $?;
    ;;
  esac
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
update)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  #i#update#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
upgrade)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  #i#upgrade#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
dist-upgrade)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  
  echo "#  FOR USE HTTP-PROXY";
  echo "#  export http_proxy='http://proxy.hostname.com:port'";
  echo "#  export https_proxy='https://proxy.hostname.com:port'";
  
  # DEPENDS : PLATFORM
  case "$platform" in
  Debian)
    sudo apt-get update #--fix-missing #--no-install-recommends
    sudo apt-get upgrade
    sudo apt-get dist-upgrade
    sudo apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline5-dev make curl git-core openjdk-7-jre-headless chkconfig || return $?;
    ;;
  Ubuntu)
    sudo apt-get update #--fix-missing
    sudo apt-get upgrade
    sudo apt-get dist-upgrade
    sudo apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline-dev make curl git-core openjdk-7-jre-headless chkconfig || return $?;
    ;;
  Redhat|Fedora|CentOS)
    sudo yum update #--fix-missing
    sudo yum -y install make curl git-core || return $?;
    echo "#  NOT YET TESTED : your contribution is welc0me";
    ;;
  esac
  
  echo "#  rvm-1.22.9 - #install"
  echo "#  rvm::ruby-2.0.0-p247 - #install"
  curl -L https://get.rvm.io | bash -s stable --ruby
  
  # --gems=rails,puma,Platform,open4,POpen4,i18n,multi_json,activesupport,
  # addressable,builder,launchy,liquid,syntax,maruku,rack,sass,rack-protection,
  # tilt,sinatra,watch,yui-compressor,bonsai,hpricot,mustache,rdiscount,ronn,
  # rails,puma;
  
  echo "#  rvm::jruby-1.7.4 - #install"
  curl -L https://get.rvm.io | bash -s stable --ruby=jruby
    
  #echo "#  rvm::gems::rails-x.x.x - #install"
  #echo "#  rvm::gems::puma-x.x.x - #install"
  #curl -L https://get.rvm.io | bash -s stable --ruby=jruby --gems=rails,puma
  
  echo "#  rvm-1.22.9 - #configure"
  [ -s "/usr/local/rvm/scripts/rvm" ] && . /usr/local/rvm/scripts/rvm;
  [ -s "~/profile_rvm" ] || cp /usr/local/rvm/scripts/rvm ~/profile_rvm;
  
  # rvm notes
  # rvm list known
  # rvm list
  # echo progress-bar >> ~/.curlrc
  
  echo "#  jq64-x.x.x - #install"
  curl -OL http://stedolan.github.io/jq/download/linux64/jq; mv jq jq64;
  echo "#  jq32-x.x.x - #install"
  curl -OL http://stedolan.github.io/jq/download/linux32/jq;
  chmod a+x jq* ; mv jq* /usr/bin/
  
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
    update  - update centrallog::logstash
    upgrade - upgrade git-centrallog::logstash
    dist-upgrade - upgrade platform with jruby::gems
_EOF_
;;
esac

unset uid gid group pass;

exit $SCRIPT_OK
