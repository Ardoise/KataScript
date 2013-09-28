#!/bin/bash -e
### BEGIN INIT INFO
# Provides: centrallog: mongodb
# Short-Description: DEPLOY SERVER: [MONGODB]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130914
### END INIT INFO

# Description: SERVICE CENTRALLOG: mongodb (...)
# - deploy mongodb v2.4.6
#
# Requires : you need root privileges tu run this script
# Requires : curl wget git-core gpg ssh
# Depends  : lib/usergroup.sh
#
# CONFIG:   [ "/etc/mongodb", "/etc/mongodb/test" ]
# BINARIES: [ "/opt/mongodb/", "/usr/share/mongodb/" ]
# LIB:      [ "/usr/lib/mongodb/", "/usr/share/lib/mongodb/" ]
# LOG:      [ "/var/log/mongodb/" ]
# RUN:      [ "/var/run/mongodb/" ]
# INIT:     [ "/etc/init.d/mongodb" ]
# CACHE:    [ "/var/cache/mongodb" ]

# @License

DESCRIPTION="MONGODB Server";
NAME="mongodb";

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
CONF_FILE=
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
  Download="http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.4.6.tgz";
  file=$(basename $Download);
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: test $Cache$NAME/$file";
  cd $Bin$NAME;
  case "$file" in
    *.tar.gz|*.tgz)
      [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -f "$Cache$NAME/$file" ] && sudo tar xvfz $Cache$NAME/$file -C $Bin$NAME/;
      cat <<-REOF >$Bin$NAME/$NAME.uninstall
      [ -d "$Bin$NAME" -a -n "$NAME" ] && rm -rf $Bin$NAME/*.*;
REOF
    ;;
    *.rpm)
      [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -f "$Cache$NAME/$file" ] && sudo rpm -ivh $Cache$NAME/$file;
      cat <<-REOF >$Bin$NAME/$NAME.uninstall
      # TODO
      #rpm -qa | grep $NAME
      #rpm -e $NAME;
      [ -d "$Bin$NAME" -a -n "$NAME" ] && rm -rf $Bin$NAME;
REOF
    ;;
    *.deb)
      [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -f "$Cache$NAME/$file" ] && sudo dpkg -i $Cache$NAME/$file --root=$Bin$NAME;
      cat <<-REOF >$Bin$NAME/$NAME.uninstall
      pkill -u $(echo $uidgid | cut -d':' -f1);
      namepkg=$(dpkg -l |grep "$NAME" |awk -F' ' '{print $2}');
      sudo dpkg -P \$namepkg
      sudo dpkg --uninstall \$namepkg
REOF
    ;;
    *.zip)
      [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -f "$Cache$NAME/$file" ] && sudo unzip $Cache$NAME/$file -d $Bin$NAME/;
      cat <<-REOF >$Bin$NAME/$NAME.uninstall
      [ -d "$Bin$NAME" -a -n "$NAME" ] && rm -rf $Bin$NAME
REOF
    ;;
    *.jar)
      [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -f "$Cache$NAME/$file" ] && sudo cp -R $Cache$NAME/$file $Bin$NAME/;
      cat <<-REOF >$Bin$NAME/$NAME.uninstall
      [ -d "$Bin$NAME/$file" -a -n "$NAME" ] && rm -f $Bin$NAME/$file
REOF
    ;;
    *)
      case "$platform" in
      Debian|Ubuntu)
        sudo apt-get update #--fix-missing
        sudo apt-get -y install $NAME;
        cat <<-REOF >$Bin$NAME/$NAME.uninstall
        sudo apt-get uninstall $NAME;
REOF
        ;;
      Redhat|Fedora|CentOS)
        sudo yum update #--fix-missing
        sudo yum -y install $NAME;
        cat <<-REOF >$Bin$NAME/$NAME.uninstall
        sudo yum uninstall $NAME;
REOF
        ;;
      esac
    ;;
  esac
  cat <<-REOF >>$Bin$NAME/$NAME.uninstall
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
  [ -f "$Bin$NAME/$NAME.uninstall" ] && cp $Bin$NAME/$NAME.uninstall /tmp/$NAME.uninstall;
  [ -f "/tmp/$NAME.uninstall" ] && sh -x /tmp/$NAME.uninstall;
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
daemon)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  CMD="null";
  case $CMD in
  *i#daemon#i*)
    exec $CMD && exit 0 || exit $?; 
    ;;
  *)
    chkconfig $NAME on && exit 0 || exit $?;
    ;;
  esac
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
nodaemon)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  CMD="null";
  case $CMD in
  *i#nodaemon#i*)
    exec $CMD && exit 0 || exit $?; 
    ;;
  *)
    chkconfig $NAME off && exit 0 || exit $?;
    ;;
  esac
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
start)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  # [ -x "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME start && exit 0 || exit $?);
null
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
  # [ -f "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME stop && exit 0 || exit $?);
null
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
  # [ -f "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME status && exit 0 || exit $?);
null
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
      libreadline5-dev make curl git-core openjdk-7-jre-headless chkconfig gpgv ssh || return $?;
    ;;
  Ubuntu)
    sudo apt-get update #--fix-missing
    sudo apt-get upgrade
    sudo apt-get dist-upgrade
    sudo apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline-dev make curl git-core openjdk-7-jre-headless chkconfig gpgv ssh || return $?;
    ;;
  Redhat|Fedora|CentOS)
    sudo yum update #--fix-missing
    sudo yum -y install make curl git-core gpg openjdk-7-jre-headless gpgv ssh || return $?;
    echo "#  NOT YET TESTED : your contribution is welc0me";
    ;;
  esac
  
  #  rvm-x.y.z - #install
  #  rvm::ruby-x.y.z - #install
  curl -L https://get.rvm.io | bash -s stable --ruby
  
  # --gems=rails,puma,Platform,open4,POpen4,i18n,multi_json,activesupport,
  # addressable,builder,launchy,liquid,syntax,maruku,rack,sass,rack-protection,
  # tilt,sinatra,watch,yui-compressor,bonsai,hpricot,mustache,rdiscount,ronn,
  # rails,puma;
  
  #  rvm::jruby-x.y.z - #install
  curl -L https://get.rvm.io | bash -s stable --ruby=jruby
    
  #echo "#  rvm::gems::rails-x.x.x - #install"
  #echo "#  rvm::gems::puma-x.x.x - #install"
  #curl -L https://get.rvm.io | bash -s stable --ruby=jruby --gems=rails,puma
  
  #  rvm-x.y.z - #configure
  [ -f "/usr/local/rvm/scripts/rvm" ] && source /usr/local/rvm/scripts/rvm;
  [ -f "~/profile_rvm" ] || sudo cp /usr/local/rvm/scripts/rvm ~/profile_rvm;
  
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
    check     - check centrallog::mongodb
    daemon    - daemon on init.d centrallog::mongodb
    nodaemon  - daemon off init.d centrallog::mongodb
    install   - install centrallog::mongodb
    reload    - reload config centrallog::mongodb
    uninstall - uninstall centrallog::mongodb
    start     - start centrallog::mongodb
    status    - status centrallog::mongodb
    stop      - stop centrallog::mongodb
    update    - update centrallog::mongodb
    upgrade   - upgrade git-centrallog::mongodb
    dist-upgrade - upgrade platform with jruby::gems
_EOF_
;;
esac

unset uid gid group pass;

exit $SCRIPT_OK
