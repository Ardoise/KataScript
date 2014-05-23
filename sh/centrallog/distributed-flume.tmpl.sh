#!/bin/bash -e

### BEGIN INIT INFO
# Provides: centrallog: flume
# Short-Description: DEPLOY SERVER: [FLUME]
# Description:  SERVICE CENTRALLOG: flume (...)
#               deploy flume v1.5.0
# Author: created by: https://github.com/Ardoise
# Copyright (c) 2013-2014 "eTopaze"
# Update: last-update: 20140116
### END INIT INFO

# Requires : you need root privileges tu run this script !
# Requires : curl wget git-core gpg ssh
# Depends  : lib/usergroup.sh
# Required-Start:    $remote_fs $syslog $network
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6

# @License
# Katascript is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

# CONFIG:   [ "/etc/flume", "/etc/flume/test" ]
# BINARIES: [ "/opt/flume/", "/usr/share/flume/" ]
# LIB:      [ "/usr/lib/flume/", "/usr/share/lib/flume/" ]
# LOG:      [ "/var/log/flume/" ]
# RUN:      [ "/var/run/flume/" ]
# INIT:     [ "/etc/init.d/flume" ]
# CACHE:    [ "/var/cache/flume" ]

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESCRIPTION="FLUME Server";
NAME="flume";
DAEMON=/var/lib/$NAME/bin/$NAME;
DAEMON_ARGS="start";
PIDFILE=/var/run/$NAME.pid;
SCRIPTNAME=/etc/init.d/$NAME;

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
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script !"
  exit $SCRIPT_ERROR
fi

using_shell=$(ps -p $$);

# Load the VERBOSE setting and other rcS variables
[ -s /lib/init/vars.sh ] && . /lib/init/vars.sh;
# Define LSB log_* functions.
[ -s /lib/lsb/init-functions ] && . /lib/lsb/init-functions;


case "$1" in
check)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  #i#check#i#
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
init|config)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
CONF_FILE=/etc/flume/flume.conf
PATTERN_FILE=
  [ ! -z "${CONF_FILE}" -a ! -z "${PATTERN_FILE}" ] && (
    curl -L ${PATTERN_FILE} -o ${CONF_FILE};
    # CONTEXT VALUES LOCAL
	sed -i 's/127.0.0.1/'${yourIP}'/g' ${CONF_FILE}
    uidgid=`${SH_DIR}/lib/usergroup.sh GET uid=$NAME form=ug`;
    chown -R $uidgid ${CONF_FILE};
  )
  
CONF_INPUT=distributed
  [ ! -z "${CONF_FILE}" -a ! -z "${CONF_INPUT}" ] && (
    curl -L ${CONF_INPUT} -o ${CONF_FILE}.input;
    # CONTEXT VALUES LOCAL
	sed -i -e 's/127.0.0.1/'${yourIP}'/g' ${CONF_FILE}.input
    uidgid=`${SH_DIR}/lib/usergroup.sh GET uid=$NAME form=ug`;
    chown -R $uidgid ${CONF_FILE}.input;
	
	echo "input {" > ${CONF_FILE}.rb
	cat ${CONF_FILE}.input >> ${CONF_FILE}.rb
	echo "}" >> ${CONF_FILE}.rb
	chown -R $uidgid ${CONF_FILE}.rb;
  )
CONF_FILTER=
  [ ! -z "${CONF_FILE}" -a ! -z "${CONF_FILTER}" ] && (
    curl -L ${CONF_FILTER} -o ${CONF_FILE}.filter;
    # CONTEXT VALUES LOCAL
    uidgid=`${SH_DIR}/lib/usergroup.sh GET uid=$NAME form=ug`;
    chown -R $uidgid ${CONF_FILE}.filter;
	
	echo "filter {" >> ${CONF_FILE}.rb
	cat ${CONF_FILE}.filter >> ${CONF_FILE}.rb
	echo "}" >> ${CONF_FILE}.rb
	chown -R $uidgid ${CONF_FILE}.rb;
  )
CONF_OUTPUT=centralized
  [ ! -z "${CONF_FILE}" -a ! -z "${CONF_OUTPUT}" ] && (
    curl -L ${CONF_OUTPUT} -o ${CONF_FILE}.output;
    # CONTEXT VALUES LOCAL
    uidgid=`${SH_DIR}/lib/usergroup.sh GET uid=$NAME form=ug`;
    chown -R $uidgid ${CONF_FILE}.output;
	
	echo "output {" >> ${CONF_FILE}.rb
	cat ${CONF_FILE}.output >> ${CONF_FILE}.rb
	echo "}" >> ${CONF_FILE}.rb
	chown -R $uidgid ${CONF_FILE}.rb;
  )
  
  # convert json to_hash
  [ -f "${CONF_FILE}.rb" ] && sed -i -e 's/ : {$/ {/g' -e 's/ : / => /g' -e 's/,$//g' ${CONF_FILE}.rb
  
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
    uid=`echo ${uidgid} | cut -d':' -f1`;
    gid=`echo ${uidgid} | cut -d':' -f2`;
  
  # LocalENV + OWNER => PROFIL
  mkdir -p $Bin$NAME || true; chown -R $uidgid $Bin$NAME || true;
  mkdir -p $Cache$NAME || true; chown -R $uidgid $Cache$NAME || true;
  mkdir -p $Etc$NAME/test || true; chown -R $uidgid $Etc$NAME || true;
  mkdir -p $Lib$NAME || true; chown -R $uidgid $Lib$NAME || true;
  mkdir -p $Log$NAME || true; chown -R $uidgid $Log$NAME || true;
  mkdir -p $Run$NAME || true; chown -R $uidgid $Run$NAME || true;

  # OWNER => PREINSTALL
  null

  # DOWNLOAD|CACHE + PROFIL => INSTALL => UNINSTALL
  Download="http://www.apache.org/dyn/closer.cgi/flume/1.5.0/apache-flume-1.5.0-bin.tar.gz";
  file=$(basename $Download);
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: test $Cache$NAME/$file";
  cd $Bin$NAME;
  case "$file" in
    *.tar.gz|*.tgz)
      [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -f "$Cache$NAME/$file" ] && sudo tar xvfz $Cache$NAME/$file -C $Bin$NAME/;
      cat <<-REOF >$Bin$NAME/$NAME.uninstall
      pkill -u $(echo $uidgid | cut -d':' -f1);
      [ -d "$Bin$NAME" -a -n "$NAME" ] && rm -rf $Bin$NAME/*.*;
REOF
    ;;
    *.rpm)
      [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -f "$Cache$NAME/$file" ] && sudo rpm -ivh $Cache$NAME/$file;
      cat <<-REOF >$Bin$NAME/$NAME.uninstall
      pkill -u $(echo $uidgid | cut -d':' -f1);
      # TODO
      #rpm -qa | grep $NAME
      #rpm -e $NAME;
      [ -d "$Bin$NAME" -a -n "$NAME" ] && rm -rf $Bin$NAME;
REOF
    ;;
    *.deb)
      [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -f "$Cache$NAME/$file" ] && (cd $Cache$NAME; sudo dpkg -i -R $file);
      cat <<-REOF >$Bin$NAME/$NAME.uninstall
      pkill -u $(echo $uidgid | cut -d':' -f1);
      namepkg=$(dpkg -l |grep "$NAME" |awk -F' ' '{print $2}');
      sudo dpkg -r \$namepkg;                     # not conf
      # sudo dpkg -P \$namepkg;                   # with conf
      # sudo dpkg --force-all --purge \$namepkg;  # with purge
REOF
    ;;
    *.zip)
      [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "$Download");
      [ -f "$Cache$NAME/$file" ] && sudo unzip $Cache$NAME/$file -d $Bin$NAME/;
      cat <<-REOF >$Bin$NAME/$NAME.uninstall
      pkill -u $(echo $uidgid | cut -d':' -f1);
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
    # [ -f "$Cache$NAME/$file" ] && rm -f "$Cache$NAME/$file"; # with purge cache
    [ -d "$Etc$NAME/test" ] && rm -rf "$Etc$NAME/test";  #noconf only package
    [ -d "$Bin$NAME" ] && rm -rf "$Bin$NAME";
    [ -d "$Log$NAME" ] && rm -rf "$Log$NAME";
    [ -d "$Lib$NAME" ] && rm -rf "$Lib$NAME";
    [ -d "$Run$NAME" ] && rm -rf "$Run$NAME";

REOF

  #i#install#i#
  [ -s /etc/default/$NAME.init ] || ( cp /etc/default/$NAME /etc/default/$NAME.init )
  [ -s /etc/default/$NAME ] && ( sed -i -e "/USER/s/USER=${NAME}$/USER=${uid}/1;/USER/s/^#//g" /etc/default/$NAME )
  [ -s /etc/default/$NAME ] && ( sed -i -e "/GROUP/s/GROUP=${NAME}$/GROUP=${gid}/1;/GROUP/s/^#//g" /etc/default/$NAME )

  # OWNER => POSTINSTALL
  null

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

  # LocalENV
  Bin="/opt/";echo "$Bin";
  Cache="/var/cache/"; echo "$Cache";
  Etc="/etc/";echo "$Etc";
  Lib="/var/lib/";echo "$Lib";
  Log="/var/log/";echo "$Log";
  Run="/var/run/";echo "$Run";

  [ -f "$Bin$NAME/$NAME.uninstall" ] && cp $Bin$NAME/$NAME.uninstall /tmp/;
  [ -f "/tmp/$NAME.uninstall" ] && sudo sh /tmp/$NAME.uninstall;
  #i#uninstall#i#
  [ -s "$Run$Name.pid" ] && kill -HUP `cat $Run$NAME.pid`;
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
    [ -s "$Run$Name.pid" ] && `cat $Run$NAME.pid`;
    ;;
  esac
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
daemon)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  CMD="chkconfig flume on";
  case $CMD in
  *i#daemon#i*)
    exec $CMD && exit 0 || exit $?; 
    ;;
  *)
    $(which sysv-rc-conf) && (sysv-rc-conf $NAME on && exit 0 || exit $?);
    $(which chkconfig) && (chkconfig $NAME on && exit 0 || exit $?);
    ;;
  esac
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
nodaemon)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  CMD="chkconfig flume off";
  case $CMD in
  *i#nodaemon#i*)
    exec $CMD && exit 0 || exit $?; 
    ;;
  *)
    $(which sysv-rc-conf) && (sysv-rc-conf $NAME off && exit 0 || exit $?);
    $(which chkconfig) && (chkconfig $NAME off && exit 0 || exit $?);
    ;;
  esac
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
start)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  # [ -x "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME start && exit 0 || exit $?);
service flume start
  case $CMD in
  *i#start#i*)
    exec $CMD && exit 0 || exit $?; 
    ;;
  *)
    service $NAME start && exit 0 || exit $?;
    [ -s "$Run$Name.pid" ] && `cat $Run$NAME.pid`; 
    ;;
  esac
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
stop)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  # [ -f "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME stop && exit 0 || exit $?);
service flume stop
  case $CMD in
  *i#stop#i*)
    exec $CMD && exit 0 || exit $?; 
    ;;
  *)
    service $NAME stop && exit 0 || exit $?;
    [ -s "$Run$Name.pid" ] && kill -HUP `cat $Run$NAME.pid`;
    ;;
  esac
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
status)
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 ...";
  # [ -f "/etc/init.d/$NAME" ] && (/etc/init.d/$NAME status && exit 0 || exit $?);
service flume status
  case $CMD in
  *i#status#i*)
    exec $CMD && exit 0 || exit $?; 
    ;;
  *)
    service $NAME status && exit 0 || exit $?;
    [ -s "$Run$Name.pid" ] && `cat $Run$NAME.pid`;
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
    sudo apt-get update; #--fix-missing #--no-install-recommends
    sudo apt-get -y upgrade;
    sudo apt-get dist-upgrade;
    sudo apt-get -y autoremove;
    sudo apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline5-dev make curl git-core openjdk-7-jre-headless chkconfig gpgv ssh || return $?;
    ;;
  Ubuntu)
    sudo apt-get update; #--fix-missing
    sudo apt-get -y upgrade;
    sudo apt-get dist-upgrade;
    sudo apt-get -y autoremove;
    sudo apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline-dev make curl git-core openjdk-7-jre-headless sysv-rc-conf gpgv ssh || return $?;
    ;;
  Redhat|Fedora|CentOS)
    sudo yum update; #--fix-missing
    sudo yum -y install make curl git-core gpg openjdk-7-jre-headless gpgv ssh || return $?;
    echo "#  NOT YET TESTED : your contribution is welc0me";
    ;;
  esac

  # Install RVM
  #  rvm-x.y.z - #install
  #  rvm::ruby-x.y.z - #install
  [ -f "/usr/local/rvm/scripts/rvm" ] || curl -sSL https://get.rvm.io | bash -s stable;
  [ -f "/usr/local/rvm/scripts/rvm" ] && . /usr/local/rvm/scripts/rvm;
  [ -f "~/.profile-rvm" ] || sudo cp /usr/local/rvm/scripts/rvm ~/.profile-rvm;
  [[ "$(grep -n '.rvm/scripts/rvm' ~/.bash_profile | cut -d':' -f1)" > 0 ]] || echo '. $HOME/.rvm/scripts/rvm' >> ~/.bash_profile;
  rvm requirements;

  echo "If old RVM installed yet";
  echo "Please do one of the following:";
  echo "* 'rvm reload'";
  echo "* open a new shell";
  echo "* 'echo rvm_auto_reload_flag=1 >> ~/.rvmrc' # for auto reload with msg.";
  echo "* 'echo rvm_auto_reload_flag=2 >> ~/.rvmrc' # for silent auto reload.";

  # TESTS UNIT SPEC
  #rvm install ruby-rspec-core;                   # TESTS UNIT SPEC
  #sudo apt-get install ruby-rspec-core           # TESTS UNIT SPEC
  #rspec spec/the/test.rb

  #Install RUBY
  #  rvm-x.y.z - #install
  #  rvm::ruby-x.y.z - #install
  curl -sSL https://get.rvm.io | bash -s stable --ruby
  #rvm install ruby
  
  #Install JRUBY
  #  rvm::jruby-x.y.z - #install
  #[ -f "/usr/local/rvm/rubies/jruby-1.7.9/bin/jruby" ] || 
  curl -sSL https://get.rvm.io | bash -s stable --ruby=jruby
  #rvm reinstall jruby
  
  # --gems=rails,puma,Platform,open4,POpen4,i18n,multi_json,activesupport,
  # addressable,builder,launchy,liquid,syntax,maruku,rack,sass,rack-protection,
  # tilt,sinatra,watch,yui-compressor,bonsai,hpricot,mustache,rdiscount,ronn,
  # rails,puma,tire;
  # curl -L https://get.rvm.io | bash -s stable --ruby=jruby --gems=rails,puma
  
  #echo "#  rvm::gems::rails-x.x.x - #install"
  #echo "#  rvm::gems::puma-x.x.x - #install"
  # rvm notes
  # rvm list known
  # rvm list
  [[ "$(grep -n 'progress-bar' ~/.curlrc | cut -d':' -f1)" > 0 ]] || echo progress-bar >> ~/.curlrc

  #GEM RUBIES
  gem update
  gem install bundler
  #gem install poi2csv
  
  #Install JSONQuery Tool
  echo "#  jq64-x.x.x - #install"
  curl -OL http://stedolan.github.io/jq/download/linux64/jq; mv jq jq64;
  echo "#  jq32-x.x.x - #install"
  curl -OL http://stedolan.github.io/jq/download/linux32/jq;
  chmod a+x jq* ; mv jq* /usr/bin/;
  
  #Install Perl
  #perl -MCPAN -e shell
  #cpan[1]> install FCGI

  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: template-$NAME : $1 [ OK ]";
;;
*)
  cat <<- _EOF_
  Commandes :
    check     - check centrallog::flume
    daemon    - daemon on init.d centrallog::flume
    nodaemon  - daemon off init.d centrallog::flume
    install   - install centrallog::flume
    reload    - reload config centrallog::flume
    uninstall - uninstall centrallog::flume
    start     - start centrallog::flume
    status    - status centrallog::flume
    stop      - stop centrallog::flume
    update    - update centrallog::flume
    upgrade   - upgrade git-centrallog::flume
    dist-upgrade - upgrade platform with jruby::gems
_EOF_
;;
esac

unset uid gid group pass;

exit $SCRIPT_OK
