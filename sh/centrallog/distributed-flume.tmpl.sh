#!/bin/bash -e

### BEGIN INIT INFO
# Provides: centrallog: flume
# Short-Description: DEPLOY SERVER: [FLUME]
# Description:  SERVICE CENTRALLOG: flume (...)
#               deploy flume v1.5.0
# Author: created by: https://github.com/Ardoise
# Copyright (c) 2013-2015 "eTopaze"
# Update: last-update: 20150511
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
# PLUGINS:  [ "/usr/share/flume/plugins" ]
# DATA:     [ "/usr/share/flume/data" ]

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

  #LocalENV
  Bin="/opt/";echo "$Bin";
  Cache="/var/cache/"; echo "$Cache";
  Etc="/etc/";echo "$Etc";
  Lib="/var/lib/";echo "$Lib";
  Log="/var/log/";echo "$Log";
  Run="/var/run/";echo "$Run";
  Plugin="/usr/share/";echo "$Plugin";
  Data="/usr/share/";echo "$Data";
  
  #OWNER
  [ -x "${SH_DIR}/lib/usergroup.sh" ] || exit 1;
  ${SH_DIR}/lib/usergroup.sh POST uid=$NAME gid=$NAME group=devops pass=$NAME;
  ${SH_DIR}/lib/usergroup.sh OPTION uid=$NAME;
  echo "PATH=\$PATH:/opt/$NAME" >/etc/profile.d/profile.add.$NAME.sh;
  uidgid=`${SH_DIR}/lib/usergroup.sh GET uid=$NAME form=ug`;
    uid=`echo ${uidgid} | cut -d':' -f1`;
    gid=`echo ${uidgid} | cut -d':' -f2`;
  
  #LocalENV + OWNER => PROFIL
  mkdir -p $Bin$NAME || true; chown -R $uidgid $Bin$NAME || true;
  mkdir -p $Cache$NAME || true; chown -R $uidgid $Cache$NAME || true;
  mkdir -p $Etc$NAME/test || true; chown -R $uidgid $Etc$NAME || true;
  mkdir -p $Lib$NAME || true; chown -R $uidgid $Lib$NAME || true;
  mkdir -p $Log$NAME || true; chown -R $uidgid $Log$NAME || true;
  mkdir -p $Run$NAME || true; chown -R $uidgid $Run$NAME || true;
  mkdir -p $Plugin$NAME/plugins || true; chown -R $uidgid $Plugin$NAME/plugins || true;
  mkdir -p $Data$NAME/data || true; chown -R $uidgid $Data$NAME/data || true;

  # OWNER => PREINSTALLS[]


  # OWNER => DOWNLOADS[]
  downloads=(
http://www.apache.org/dyn/closer.cgi/flume/1.5.0/apache-flume-1.5.0-bin.tar.gz
http://www.apache.org/dyn/closer.cgi/flume/1.5.0/apache-flume-1.5.0-src.tar.gz
  );

  for d in "${downloads[@]}"; do
    file=$(basename ${d});
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: test $Cache$NAME/$file";
    cd $Bin$NAME;
    case "$file" in
      *.tar.gz|*.tgz)
        [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "${d}");
        [ -f "$Cache$NAME/$file" ] && sudo tar xvfz $Cache$NAME/$file -C $Bin$NAME/;
        cat <<-REOF >$Bin$NAME/$NAME.uninstall
        pkill -u $(echo $uidgid | cut -d':' -f1);
        [ -d "$Bin$NAME" -a -n "$NAME" ] && rm -rf $Bin$NAME/*.*;
REOF
      ;;
      *.rpm)
        [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "${d}");
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
        [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "${d}");
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
        [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "${d}");
        [ -f "$Cache$NAME/$file" ] && sudo unzip $Cache$NAME/$file -d $Bin$NAME/;
        cat <<-REOF >$Bin$NAME/$NAME.uninstall
        pkill -u $(echo $uidgid | cut -d':' -f1);
        [ -d "$Bin$NAME" -a -n "$NAME" ] && rm -rf $Bin$NAME
REOF
      ;;
      *.jar)
        [ -f "$Cache$NAME/$file" ] || (cd $Cache$NAME; sudo curl -OL "${d}");
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
  done #downloads

  cat <<-REOF >>$Bin$NAME/$NAME.uninstall
    # [ -f "$Cache$NAME/$file" ] && rm -f "$Cache$NAME/$file"; # with purge cache
    [ -d "$Etc$NAME/test" ] && rm -rf "$Etc$NAME/test";  #noconf only package
    [ -d "$Bin$NAME" ] && rm -rf "$Bin$NAME";
    [ -d "$Log$NAME" ] && rm -rf "$Log$NAME";
    [ -d "$Lib$NAME" ] && rm -rf "$Lib$NAME";
    [ -d "$Run$NAME" ] && rm -rf "$Run$NAME";
    [ -d "$Plugin$NAME/plugins" ] && rm -rf "$Plugin$NAME/plugins";
    [ -d "$Data$NAME/data" ] && echo "RUN rm -rf $Data$NAME/data";
  
REOF

  #i#install#i#
  [ -s /etc/default/$NAME.init ] || ( cp /etc/default/$NAME /etc/default/$NAME.init )
  [ -s /etc/default/$NAME ] && ( sed -i -e "/USER/s/USER=${NAME}$/USER=${uid}/1;/USER/s/^#//g" /etc/default/$NAME )
  [ -s /etc/default/$NAME ] && ( sed -i -e "/GROUP/s/GROUP=${NAME}$/GROUP=${gid}/1;/GROUP/s/^#//g" /etc/default/$NAME )

  # OWNER => POSTINSTALLS[]


  chown -R $uidgid $Cache$NAME || true;
  chown -R $uidgid $Etc$NAME || true;
  chown -R $uidgid $Lib$NAME || true;
  chown -R $uidgid $Log$NAME || true;
  chown -R $uidgid $Run$NAME || true;
  chown -R $uidgid $Bin$NAME || true;
  chown -R $uidgid $Plugin$NAME/plugins || true;
  chown -R $uidgid $Data$NAME/data || true;
    
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
  Plugin="/usr/share/";echo "$Plugin";
  Data="/usr/share/";echo "$Data";

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
  chkconfig flume on;
  CMD="#i#daemon#i#";
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
  chkconfig flume off;
  CMD="#i#nodaemon#i#";
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
  
  echo "#  TO USE HTTP-PROXY";
  echo "#  export http_proxy='http://user@yourproxy.com:port'";
  echo "#  export https_proxy='https://user@yourproxy.com:port'";
  echo "#  export USEPROXY=1";
  
  # DEPENDS : PLATFORM
  case "$platform" in
  Debian)
    sudo apt-get update; #--fix-missing #--no-install-recommends
    sudo apt-get -y upgrade;
    sudo apt-get dist-upgrade;
    sudo apt-get -y autoremove;
    sudo apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline5-dev make curl git-core openjdk-8-jre-headless chkconfig gpgv ssh wget;
    ;;
  Ubuntu)
    sudo apt-get update; #--fix-missing
    sudo apt-get -y upgrade;
    sudo apt-get dist-upgrade;
    sudo apt-get -y autoremove;
    sudo apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline-dev make curl git-core openjdk-8-jre-headless sysv-rc-conf gpgv ssh libcurl4-openssl-dev wget realpath;
    ;;
  Redhat|Fedora|CentOS)
    sudo yum update; #--fix-missing
    sudo yum -y install make curl git-core gpg openjdk-8-jre-headless gpgv ssh \
      openssl-devel gcc curl wget git python-devel realpath;
    echo "#  NOT YET TESTED : your contribution is welc0me";
    ;;
  esac

  #rvm-x.y.z - #install
  #rvm::ruby-x.y.z - #install
  [ -f "/usr/local/rvm/scripts/rvm" ] || (
    echo "#  Install RVM##1.25.33";
    curl -sSL https://get.rvm.io | bash -s stable;
  )
  [ -f "/usr/local/rvm/scripts/rvm" ] && . /usr/local/rvm/scripts/rvm;
  [[ "$(grep -n 'rvm/scripts/rvm' ${HOME}/.bash_profile |cut -d':' -f1)" > 0 ]] || echo '. /usr/local/rvm/scripts/rvm' >> ${HOME}/.bash_profile;
  rvm requirements;
  #Installing required packages: gawk, libyaml-dev, libsqlite3-dev, sqlite3, autoconf, libgdbm-dev, libncurses5-dev, automake, libtool, bison, libffi-dev...

  #DEPRECATED
  # echo "#  If old RVM installed yet";
  # echo "#  Please do one of the following:";
  # echo "#    'rvm reload'";
  # echo "#    'open a new shell'";
  # echo "#    'echo rvm_auto_reload_flag=1 >> ${HOME}/.rvmrc' # for auto reload with msg.";
  # echo "#    'echo rvm_auto_reload_flag=2 >> ${HOME}/.rvmrc' # for silent auto reload.";

  echo "#  Install RUBY##2.1.3";
  #  rvm-x.y.z - #install
  #  rvm::ruby-x.y.z - #install
  curl -sSL https://get.rvm.io |bash -s stable --ruby
  #rvm reinstall ruby
  
  echo "#  Install JRUBY##1.7.16";
  #rvm::jruby-x.y.z - #install
  #[ -f "/usr/local/rvm/rubies/jruby-1.7.16/bin/jruby" ] || 
  curl -sSL https://get.rvm.io |bash -s stable --ruby=jruby
  #rvm reinstall jruby
  
  # --gems=rails,puma,Platform,open4,POpen4,i18n,multi_json,activesupport,
  # addressable,builder,launchy,liquid,syntax,maruku,rack,sass,rack-protection,
  # tilt,sinatra,watch,yui-compressor,bonsai,hpricot,mustache,rdiscount,ronn,
  # rails,puma,tire;
  # curl -L https://get.rvm.io |bash -s stable --ruby=jruby --gems=rails,puma
  
  #echo "#  rvm::gems::rails-x.x.x - #install"
  #echo "#  rvm::gems::puma-x.x.x - #install"
  # rvm notes
  # rvm list known
  # rvm list
  [[ "$(grep -n 'progress-bar' ${HOME}/.curlrc |cut -d':' -f1)" > 0 ]] || echo progress-bar >> ${HOME}/.curlrc

  #Install GEM RUBIES
  gem update
  gem install bundler
  #gem install poi2csv
  
  echo "#  Install JSONQuery Parser";
  echo "#    jq64-x.x.x - #install"
  curl -OL http://stedolan.github.io/jq/download/linux64/jq;
  echo "#    jq32-x.x.x - #install"
  curl -OL http://stedolan.github.io/jq/download/linux32/jq; mv jq jq32;
  chmod a+x jq* ; mv jq* /usr/bin/;
  
  #Install Perl
  #perl -MCPAN -e shell
  #cpan[1]> install FCGI

   case "$platform" in
   Ubuntu|Debian)
     #Install PYTHON3##3.1.4
     sudo apt-get -y install -y python3;
     sudo apt-get -y install -y python3-dev;  #bibliothèques avec des extensions en C
     sudo apt-get -y install -y python3-pip;

     echo "#  detect python2 : $(python2 --version 2>&1)";
     echo "#  detect python3 : $(python3 --version 2>&1)";
     echo "#  detect python  : $(python  --version 2>&1)";  
     echo "#  detect pip : $(pip --version 2>&1)";
     python3 ${SH_DIR}/py/hello.py;

     #Package Distribution
     sudo apt-get install -y uwsgi-plugins-all; #OPTION

     #Package Distribution
     echo "sudo dpkg-reconfigure locales -a";
     ;;
   Redhat|Fedora|CentOS)
     #Install PYTHON2##2.7.1
#     cat <<EOF >/etc/yum.repos.d/scl_python27.repo
# [scl_python27]
# name=Python 2.7 Dynamic Software Collection
# baseurl=http://people.redhat.com/bkabrda/python27-rhel-6/
# failovermethod=priority
# enabled=1
# gpgcheck=0
# EOF
     yum update
     yum search python27
     echo "#     yum install python27"

#     #Install PYTHON3##3.3.1
#     cat <<EOF >/etc/yum.repos.d/scl_python33.repo
# [scl_python33]
# name=Python 3.3 Dynamic Software Collection
# baseurl=http://people.redhat.com/bkabrda/python33-rhel-6/
# failovermethod=priority
# enabled=1
# gpgcheck=0
# EOF
     yum update
     yum search python33
     echo "#     yum install python33"

#     #Install RUBY##1.9.1
#     cat <<EOF >/etc/yum.repos.d/scl_ruby193.repo
# [scl_ruby193]
# name=Ruby 1.9.3 Dynamic Software Collection
# baseurl=http://people.redhat.com/bkabrda/ruby193-rhel-6/
# failovermethod=priority
# enabled=1
# gpgcheck=0
# EOF
     yum update
     yum search ruby193
     ;;
   esac
  
  #==========
  echo "#  install PYTHON3#3.4.2 from source"
  #========== SOURCE
  PYTHON_VERSION=3.4;
  PYTHON_VERSION_SRC=${PYTHON_VERSION}.2;
  PYTHON_FILE_SRC="Python-${PYTHON_VERSION_SRC}.tar.xz";
  PYTHON_URI_SRC=https://www.python.org/ftp/python/${PYTHON_VERSION_SRC}/${PYTHON_FILE_SRC};
  cd /tmp
  wget ${PYTHON_URI_SRC}
  tar xJf ./${PYTHON_FILE_SRC};
  cd ./${PYTHON_FILE_SRC%%.tar.xz};
  [ -d /opt/python${PYTHON_VERSION}/lib/python${PYTHON_VERSION} ] || (
    ./configure --prefix=/opt/python${PYTHON_VERSION};
    make && sudo make install;
  )
  #
  #PYTHON_ALIAS='alias py="/opt/python'${PYTHON_VERSION}'/bin/python3";';
  PYTHON_ALIAS='alias py="/opt/python3.4/bin/python3";';
  for a in ${HOME}/.bashrc ${HOME}/.bash_aliases; do
    sed 's~alias py=.*~~' ${a} >${a}.kstmp; #previous if exist
    echo ${PYTHON_ALIAS} >> ${a}.kstmp;
    mv ${a}.kstmp ${a};
    . ${a};
  done
  echo "#    use python with python${PYTHON_VERSION}";

  #==========
  echo "#  install PIP#1.5.4 from source [RECOMMENDED]";
  #==========
  cd /tmp;
  curl -OL https://bootstrap.pypa.io/get-pip.py
  echo '#    python get-pip.py --proxy="[user:passwd@]proxy.server:port"'
  python${PYTHON_VERSION} get-pip.py
  python${PYTHON_VERSION} -m pip --version
  python${PYTHON_VERSION} -m pip install -U pip

  #==========
  echo "#  install VIRTUALENV|SETUPTOOLS with pip";
  #==========
  python${PYTHON_VERSION} -m pip install --upgrade virtualenv
  python${PYTHON_VERSION} -m virtualenv --version
  python${PYTHON_VERSION} -m pip install --upgrade setuptools

  #python2   -m pip install SomePackage  # default Python 2
  #python2.7 -m pip install SomePackage  # specifically Python 2.7
  #python3   -m pip install SomePackage  # default Python 3
  #python3.4 -m pip install SomePackage  # specifically Python 3.4

  #==========
  #echo "#  install VIRTUALENV#1.9.7 from source"
  #========== SOURCE
  [ -d /opt/virtualenv ] || mkdir -p /opt/virtualenv
  cd /tmp
  #curl -O https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.9.tar.gz
  #tar xvfz virtualenv-1.9.tar.gz
  #sudo mv virtualenv-1.9 /opt/virtualenv
  cd /opt/virtualenv;
  #echo "#     To install globally from source:"
  #python${PYTHON_VERSION} setup.py install
  #echo "#     To use locally from source:"
  #installation d'1 env. /opt/virtual/p3
  #sudo $(which python3) virtualenv.py p3

  for p in p3 p34; do
    home=/opt/virtualenv;
    project=${p};

    [ -d ${home} ] || mkdir -p ${home};
    [ -d ${home} ] && cd ${home};
    
    #-p /usr/bin/python2
    #-p /usr/bin/python2.7
    #-p /usr/bin/python3
    #-p /usr/bin/python3.4
    
    #echo "#  install packages#x.y.z"
    #for this version : ONLY UID=ROOT CAN DO THAT !!!
    #next version await (--user) used

    echo "#    virtualenv=$(virtualenv --version) must be necessary >1.10"
    case ${project} in
      p3)
        eval VIRTUALENV_PYTHON=$(realpath $(which python3));
        export VIRTUALENV_PYTHON;
        echo "#    create env Python3 with VIRTUALENV_PYTHON=${VIRTUALENV_PYTHON}"
        #PACKAGE SYSTEM DISTRIB
        sudo virtualenv -p python${PYTHON_VERSION} /opt/virtualenv/${project}
        echo "#    source /opt/virtualenv/${project}/bin/activate";
        . /opt/virtualenv/${project}/bin/activate
      ;;
      p34)
        #PACKAGE LOCAL
        export VIRTUALENV_PYTHON=/opt/python${PYTHON_VERSION}/bin/python${PYTHON_VERSION};
        echo "#    create env Python3 with VIRTUALENV_PYTHON=${VIRTUALENV_PYTHON}"
        sudo virtualenv -p /opt/python${PYTHON_VERSION}/bin/python${PYTHON_VERSION} /opt/virtualenv/${project}
        echo "#    source /opt/virtualenv/${project}/bin/activate";
        . /opt/virtualenv/${project}/bin/activate
      ;;
    esac
    
    python${PYTHON_VERSION} -m pip --version
    python${PYTHON_VERSION} -m pip list
    python${PYTHON_VERSION} -m pip install --upgrade libxml2; #BUG
    python${PYTHON_VERSION} -m pip install --upgrade libxslt;
    python${PYTHON_VERSION} -m pip install --upgrade lxml; #BUG
    python${PYTHON_VERSION} -m pip install --upgrade elasticsearch;
    python${PYTHON_VERSION} -m pip install --upgrade virtualenv;
    python${PYTHON_VERSION} -m pip install --upgrade virtualenvwrapper;
    python${PYTHON_VERSION} -m pip install --upgrade urllib3;
    python${PYTHON_VERSION} -m pip install --upgrade pyOpenSSL;
    python${PYTHON_VERSION} -m pip install --upgrade jinja2; #.markupsafe .itsdangerous .werkzeug
    python${PYTHON_VERSION} -m pip install --upgrade flask;
    python${PYTHON_VERSION} -m pip install --upgrade flask-script;
    python${PYTHON_VERSION} -m pip install --upgrade uwsgi;
    python${PYTHON_VERSION} -m pip install --upgrade pycurl; #BUG
    python${PYTHON_VERSION} -m pip install --upgrade pyparsing;
    python${PYTHON_VERSION} -m pip install --upgrade pycrypto;
    python${PYTHON_VERSION} -m pip install --upgrade requests;
    python${PYTHON_VERSION} -m pip install --upgrade paramiko; #.ecdsa
    python${PYTHON_VERSION} -m pip install --upgrade oauthlib;
    python${PYTHON_VERSION} -m pip install --upgrade html5lib;
    python${PYTHON_VERSION} -m pip install --upgrade httplib2;
    python${PYTHON_VERSION} -m pip install --upgrade markdown;
    python${PYTHON_VERSION} -m pip install --upgrade google-api-python-client;
    python${PYTHON_VERSION} -m pip install --upgrade python-oauth2;
    python${PYTHON_VERSION} -m pip install --upgrade pip-tools;
    python${PYTHON_VERSION} -m pip install --upgrade freeze;
    python${PYTHON_VERSION} -m pip freeze -l;

    deactivate

    chown -R www-data:www-data /opt/virtualenv

    #==========
    echo "#  to USE RUNTIME VIRTUALENV"
    #==========
    echo "source /opt/virtualenv/p3/bin/activate";
    echo "# ... operations ...#";
    echo "#  deactivate";
    # TESTED OK
  done

  #==========
  echo "#  install UWSGI#2.0.7 from source [OPTION]"
  #========== SOURCE
  [ -d /opt ] || mkdir -p /opt
  cd /opt
  curl http://uwsgi.it/install |sudo bash -s default /opt/uwsgi
  /opt/uwsgi --version
  chown www-data:www-data /opt/uwsgi
  rm -rf uwsgi_latest_from_installer*
  chown www-data:www-data /opt/uwsgi; #HTTP SERVER USED

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
    dist-upgrade - upgrade platform with jruby::gems python3::pip3
_EOF_
;;
esac

unset uid gid group pass;

exit $SCRIPT_OK
