#!/bin/bash -e

### BEGIN INIT INFO
# Provides: centrallog: mongodb
# Short-Description: DEPLOY SERVER: [MONGODB]
# Description:  SERVICE CENTRALLOG: mongodb (...)
#               deploy mongodb v2.6.3
# Author: created by: https://github.com/Ardoise
# Copyright (c) 2013-2015 "eTopaze"
# Update: last-update: 20150512
### END INIT INFO

# Requires : you need root privileges tu run this script !
# Requires : curl wget git-core gpg ssh sudo
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

# CONFIG:   [ "/etc/mongodb", "/etc/mongodb/test" ]
# BINARIES: [ "/opt/mongodb/", "/usr/share/mongodb/" ]
# LIB:      [ "/usr/lib/mongodb/", "/usr/share/lib/mongodb/" ]
# LOG:      [ "/var/log/mongodb/" ]
# RUN:      [ "/var/run/mongodb/" ]
# INIT:     [ "/etc/init.d/mongodb" ]
# CACHE:    [ "/var/cache/mongodb" ]
# PLUGINS:  [ "/usr/share/mongodb/plugins" ]
# DATA:     [ "/usr/share/mongodb/data" ]

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESCRIPTION="MONGODB Server";
NAME="mongodb";
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
WWW_DATA="www-data";

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
CONF_FILE=
PATTERN_FILE=
  [ ! -z "${CONF_FILE}" -a ! -z "${PATTERN_FILE}" ] && (
    curl -L ${PATTERN_FILE} -o ${CONF_FILE};
    # CONTEXT VALUES LOCAL
	sed -i 's/127.0.0.1/'${yourIP}'/g' ${CONF_FILE}
    uidgid=`${SH_DIR}/lib/usergroup.sh GET uid=$NAME form=ug`;
    chown -R $uidgid ${CONF_FILE};
  )
  
CONF_INPUT=
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
CONF_OUTPUT=
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
https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.6.3.tgz
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
    #
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
  null;
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
  null;
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
null
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
null
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
null
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
  
  echo "#   TO USE HTTP-PROXY";
  echo "#   export http_proxy='http://user@yourproxy.com:port/'";
  echo "#   export https_proxy='https://user@yourproxy.com:port/'";
  echo "#   export ftp_proxy='https://user@yourproxy.com:port/'";
  echo "#   export USEPROXY=1";
  
  # DEPENDS : PLATFORM
  case "$platform" in
  Ubuntu|Debian)
    sudo apt-get update; #--fix-missing #--no-install-recommends
    sudo apt-get -y upgrade;
    sudo apt-get -y install build-essential zlib1g-dev libssl-dev sudo \
      libreadline-dev make curl git-core openjdk-8-jre-headless sysv-rc-conf gpgv ssh libcurl4-openssl-dev wget realpath;
    ;;
  Redhat|Fedora|CentOS)
    sudo yum update; #--fix-missing
    sudo yum -y upgrade;
    sudo yum -y install make curl git-core gpg openjdk-8-jre-headless gpgv ssh sudo \
      openssl-devel gcc curl wget git python-devel realpath;
    echo "#   NOT REAL TESTED : your contribution is welc0me";
    ;;
  esac

  #==========
  echo && echo "#   Checking RVM##X.Y.Z";
  #==========
  #rvm-x.y.z - #install
  #rvm::ruby-x.y.z - #install
  [ -r "/usr/local/rvm/scripts/rvm" ] && . /usr/local/rvm/scripts/rvm;
  vrvm=$(rvm --version |awk '{print $2}'); #RULE
  if [[ "$vrvm" < "1.26.10" ]]; then
    echo "#  Install RVM##X.Y.Z stable";
    curl -sSL https://rvm.io/mpapis.asc |sudo gpg --import -
    curl -sSL https://get.rvm.io |bash -s stable; #rvm 1.26.11
    [ -f "/usr/local/rvm/scripts/rvm" ] && . /usr/local/rvm/scripts/rvm;
    vrvm=$(rvm --version |awk '{print $2}'); #RULE
    [[ "$(grep -n 'rvm/scripts/rvm' ${HOME}/.bash_profile |cut -d':' -f1)" > 0 ]] || echo '. /usr/local/rvm/scripts/rvm' >> ${HOME}/.bash_profile;
    [[ "$(grep -n 'progress-bar' ${HOME}/.curlrc |cut -d':' -f1)" > 0 ]] || echo progress-bar >> ${HOME}/.curlrc
    [ -r "/usr/local/rvm/scripts/rvm" ] && . /usr/local/rvm/scripts/rvm;

    rvm requirements;
  fi
  echo "#   Requirements RVM##${vrvm} successful";
  #Installing required packages: gawk, libyaml-dev, libsqlite3-dev, sqlite3, autoconf, libgdbm-dev, libncurses5-dev, automake, libtool, bison, libffi-dev...

  #==========
  echo && echo "#   Checking RUBY##X.Y.Z";
  #==========
  #  rvm-x.y.z - #install
  #  rvm::ruby-x.y.z - #install
  vruby=$(ruby --version |awk '{print $2}'); #RULE
  if [[ "${vruby}" < "2.1.2" ]]; then
    curl -sSL https://get.rvm.io |bash -s stable --ruby; #ruby 2.2.1
    vruby=$(ruby --version |awk '{print $2}');
  fi
  echo "#   Requirements RUBY##${vruby} successful";
  #rvm reinstall ruby
  
  # #==========
  # echo && echo "#   Checking JRUBY##X.Y.Z";
  # #==========
  # #rvm::jruby-x.y.z - #install
  # vjruby=$(jruby --version |awk '{print $2}'); #RULE
  # if [[ "$jruby" < "1.5.6-9" ]]; then
  #   curl -sSL https://get.rvm.io |bash -s stable --ruby=jruby; #/usr/local/rvm/rubies/jruby-1.7.19/bin/jruby"
  #   [ -f "/usr/local/rvm/scripts/rvm" ] && . /usr/local/rvm/scripts/rvm;
  #   vjruby=$(jruby --version |awk '{print $2}');
  # fi
  # echo "#   Requirements JRUBY##${vjruby} successful";
  # #rvm reinstall jruby
  
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

  #==========
  echo && echo "#   Checking GEM##X.Y.Z";
  #==========
  vgem=$(gem --version |awk '{print $1}'); #RULE
  if [[ "$vgem" < "2.2.1" ]]; then
    gem update ;

    echo "#   update GEM##RUBIES";
    gem install bundler

    vgem=$(gem --version |awk '{print $1}');
  fi
  echo "#   Requirements GEM##${vgem} successful";
  
  #gem install poi2csv
  
  #==========
  echo && echo "#   Install JSONQuery Parser";
  #==========
  vjq=$(jq --version |awk -F'-' '{print $2}'); #RULE
  if [[ "$vjq" < "1.3" ]]; then
    case $(uname -m) in
      *64) #64 bits = x86_64
        echo "#   Requirements JQ##64b successful";
        curl -OL http://stedolan.github.io/jq/download/linux64/jq;
      ;;
      *) #32bits = i386, i686
        echo "#   Requirements JQ##32b successful";
        curl -OL http://stedolan.github.io/jq/download/linux32/jq;
      ;;
    esac
    chmod a+x jq* ; mv jq* /usr/bin/;
    vjq=$(jq --version |awk -F'-' '{print $2}');
  fi
  echo "#   Requirements JQ##${vjq} successful";

  #Install Perl
  #perl -MCPAN -e shell
  #cpan[1]> install FCGI

  #==========
  echo && echo "#   Install Primary PYTHON3|PYTHON2 from binaries"; #PRIMARY PYTHON (eq. make install))
  #==========
  case "$platform" in
   Ubuntu|Debian)
     #Install PYTHON2##2.7.9
     sudo apt-get -y install python-pip;
     # python-colorama python-distlib python-html5lib python-ndg-httpsclient python-requests 
     # python-setuptools python-urllib3 python-wheel
     
     # Suggested packages:
     #  python-genshi python-lxml
     
     # Recommended packages:
     #  python-dev-all

     echo "#  detect python  : $(python  --version 2>&1)";  
     echo "#  detect python2 : $(python2 --version 2>&1)";
     echo "#  detect pip : $(pip --version 2>&1)";

     #Install PYTHON3##3.4.3
     sudo apt-get -y install python3-pip;
     # binutils build-essential cpp cpp-4.9 dpkg-dev fakeroot g++ g++-4.9 gcc gcc-4.9 
     # libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libasan1 
     # libatomic1 libc-dev-bin libc6-dev libcilkrts5 libcloog-isl4 libdpkg-perl libexpat1-dev 
     # libfakeroot libfile-fcntllock-perl libgcc-4.9-dev libgomp1 libisl13 libitm1 libmpc3 
     # libpython3-dev libpython3.4 libpython3.4-dev libquadmath0 libstdc++-4.9-dev 
     # libubsan0 linux-libc-dev make manpages-dev python3-colorama python3-dev 
     # python3-distlib python3-html5lib python3-setuptools python3-wheel python3.4-dev

     # Suggested packages:
     #  binutils-doc cpp-doc gcc-4.9-locales debian-keyring g++-multilib g++-4.9-multilib 
     #  gcc-4.9-doc libstdc++6-4.9-dbg gcc-multilib autoconf automake libtool flex bison 
     #  gdb gcc-doc gcc-4.9-multilib libgcc1-dbg libgomp1-dbg libitm1-dbg libatomic1-dbg 
     #  libasan1-dbg liblsan0-dbg libtsan0-dbg libubsan0-dbg libcilkrts5-dbg libquadmath0-dbg 
     #  glibc-doc libstdc++-4.9-doc make-doc python3-genshi python3-lxml

     #sudo apt-get -y install libpython3-dev libpython3.4 libpython3.4-dev
     #sudo apt-get -y install python3-dev python3-distlib python3-html5lib python3-setuptools python3-wheel python3.4-dev
     #sudo apt-get -y install -y python3.4-dev;  #bibliothèques avec des extensions en C

     echo "#  detect python3 : $(python3 --version 2>&1)";
     echo "#  detect pip3 : $(pip3 --version 2>&1)";  #pip 1.5.6 from /usr/lib/python3/dist-packages (python 3.4)
     #python3 ${SH_DIR}/py/hello.py;

     #Package Distribution

     #sudo apt-get install -y uwsgi-plugins-all; #OPTION
     # fontconfig-config fonts-dejavu-core libfontconfig1 libgloox12 libjansson4 libjs-jquery 
     # liblua5.1-0 libmatheval1 libperl5.20 libpgm-5.1-0 libphp5-embed libpq5 libruby2.1 libsodium13
     # libv8-3.14.5 libyaml-0-2 libzmq3 openjdk-7-jre-headless php5-common python-greenlet ruby 
     # ruby2.1 rubygems-integration sqlite3 tzdata-java uwsgi-app-integration-plugins uwsgi-core 
     # uwsgi-infrastructure-plugins uwsgi-plugin-alarm-curl uwsgi-plugin-alarm-xmpp 
     # uwsgi-plugin-curl-cron uwsgi-plugin-emperor-pg uwsgi-plugin-fiber uwsgi-plugin-geoip 
     # uwsgi-plugin-graylog2 uwsgi-plugin-greenlet-python uwsgi-plugin-jvm-openjdk-7 
     # uwsgi-plugin-jwsgi-openjdk-7 uwsgi-plugin-ldap uwsgi-plugin-lua5.1 uwsgi-plugin-lua5.2 
     # uwsgi-plugin-luajit uwsgi-plugin-php uwsgi-plugin-psgi uwsgi-plugin-python uwsgi-plugin-python3
     # uwsgi-plugin-rack-ruby2.1 uwsgi-plugin-rados uwsgi-plugin-rbthreads uwsgi-plugin-router-access 
     # uwsgi-plugin-sqlite3 uwsgi-plugin-v8 uwsgi-plugin-xslt uwsgi-plugins-all

     # Suggested packages:
     #  javascript-common php-pear icedtea-7-jre-jamvm libnss-mdns sun-java6-fonts fonts-dejavu-extra 
     #  fonts-ipafont-gothic fonts-ipafont-mincho ttf-wqy-microhei ttf-wqy-zenhei fonts-indic 
     #  php5-user-cache python-greenlet-doc python-greenlet-dev python-greenlet-dbg ri ruby-dev 
     #  bundler sqlite3-doc nginx-full cherokee libapache2-mod-proxy-uwsgi libapache2-mod-uwsgi 
     #  libapache2-mod-ruwsgi uwsgi-extra python-uwsgidecorators python3-uwsgidecorators

     sudo apt-get install -y python3-venv; #OPTION #REPLACE the DEPRECATED VIRTUALENV
     # python-chardet-whl python-colorama-whl python-distlib-whl python-html5lib-whl python-pip-whl 
     # python-requests-whl python-setuptools-whl python-six-whl python-urllib3-whl python3.4-venv

     #echo "sudo dpkg-reconfigure locales -a";

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
  echo && echo "#   Checking PYTHON3##X.Y.Z";
  #==========
  vpython3=$(python3 --version |awk '{print $2}'); #RULE
  if [[ "$vpython3" < "3.4.1" ]]; then
      #==========
      echo "#   altinstall PYTHON3#3.4.3 from source"; #MULTIPLE PYTHON (eq. make altinstall))
      #========== SOURCE
      PYTHON_VERSION=3.4;
      PYTHON_VERSION_SRC=${PYTHON_VERSION}.3;
      PYTHON_FILE_SRC="Python-${PYTHON_VERSION_SRC}.tar.xz";
      PYTHON_URI_SRC=https://www.python.org/ftp/python/${PYTHON_VERSION_SRC}/${PYTHON_FILE_SRC};
      prefix=/opt/python${PYTHON_VERSION};

      cd /tmp;
      wget ${PYTHON_URI_SRC}
      tar xJf ./${PYTHON_FILE_SRC};
      cd ./${PYTHON_FILE_SRC%%.tar.xz};
      [ -d ${prefix}/lib/python${PYTHON_VERSION} ] || (
        ./configure --prefix=${prefix};

        #The necessary bits to build these optional modules were not found:
        #_bz2                  _curses               _curses_panel      
        #_dbm                  _gdbm                 _lzma              
        #_sqlite3              _ssl                  _tkinter           
        #readline              zlib
        case "$platform" in 
          Ubuntu|Debian)
            sudo apt-get update;
            #REQUIRES for Python3 src
            sudo apt-get install -y zlib1g-dev libbz2-dev libcurses5-dev tcl8.6-dev tk8.6-dev liblzma-dev;
            sudo apt-get install -y libreadline-dev libreadline6-dev libgdm-dev libgdm3-dev libssl-dev libsqlite3-dev python3-tk;
          ;;
          Redhat|Fedora|CentOS)
            yum -y update;
          ;;
        esac
      
        echo "#    at first, wait a moment ... [390*5] test_ressource ";
        make && make test && sudo make altinstall; #for others python
      )
      #
      PYTHON_ALIAS='alias py="'${prefix}'/bin/python3";';
      for a in ${HOME}/.bashrc ${HOME}/.bash_aliases; do
        sed 's~alias py=.*~~' ${a} >${a}.kstmp; #previous if exist
        echo ${PYTHON_ALIAS} >> ${a}.kstmp;
        mv ${a}.kstmp ${a};
        . ${a};
      done
      echo "#    use python with python${PYTHON_VERSION}";

      vpython3=$(python3 --version |awk '{print $2}');
  fi
  echo "#   Requirements PYTHON3##${vpython3} successful";

  #==========
  echo && echo "#   Checking PIP##X.Y.Z";
  #==========
  vpip=$(python -m pip --version |awk '{print $2}');
  if [[ "$vpip" < "1.5.5" ]]; then
      # #==========
      echo "#   install PIP#1.5.6 from source"; #/usr/local/lib/python3.4/dist-packages
      # #==========
      cd /tmp;
      curl -OL https://bootstrap.pypa.io/get-pip.py
      echo '#    python get-pip.py --proxy="[user:passwd@]proxy.server:port"'
      python get-pip.py
      python -m pip --version
      python -m pip install -U pip
      vpip=$(python -m pip --version |awk '{print $2}');
  fi
  echo "#   Requirements PIP##${vpip} successful";

  # USE pyvenv instead-of virtualenv
  #==========
  echo && echo "#   Checking PYVENV##X.Y.Z";
  #========== SOURCE
  if [ "$(which pyvenv 2>/dev/null)a" != "a" ]; then

        
    for p in p34; do

      home=/opt/venv;
      project=${p};

      [ -d ${home} ] || mkdir -p ${home};
      [ -d ${home} ] && cd ${home};
          
      #echo "#    venv=$(venv --version) must be necessary >1.10" (DEPRECATED)
      case ${project} in
        p34)
          #PACKAGE VIRTUAL ENV
          #eval VENV_PYTHON=$(realpath $(which python3));
          export VENV_PYTHON=${prefix}/bin/python${PYTHON_VERSION};
          echo "#    create env Python3 with VENV_PYTHON=${VENV_PYTHON}"
          #sudo venv -p /opt/python${PYTHON_VERSION}/bin/python${PYTHON_VERSION} /opt/venv/${project} (DEPRECATED)
          sudo pyvenv /opt/venv/${project}
          echo "#    source /opt/venv/${project}/bin/activate";
          . /opt/venv/${project}/bin/activate

              # ===============
          echo "#     upgrade modules PIP"
          # ===============
          echo "#     check permission ${HOME}/.cache/pip/log"
          
          chmod -R 777 ${HOME}/.cache; #${HOME}/.cache/pip/log/debug.log
          chown -R root:root ${HOME}/.cache; #${HOME}/.cache/pip/log/debug.log

          #python${PYTHON_VERSION} -m pip install --upgrade SomePackage
          #python${PYTHON_VERSION} -m SomePackage --version
          python --version
          python -m pip --version
          python -m pip list

          #python -m pip install --upgrade apturl; #  (0.5.2ubuntu6)
          #python -m pip install --upgrade bsddb3; # (6.1.0)
          #python -m pip install --upgrade chardet; # (2.3.0)
          #python -m pip install --upgrade colorama; # (0.3.2)
          #python -m pip install --upgrade command-not-found; # (0.3)
          #python -m pip install --upgrade defer; # (1.0.6)
          #python -m pip install --upgrade gramps; # (4.1.1)
          python -m pip install --upgrade html5lib; # (0.999) .six
          #python -m pip install --upgrade language-selector; # (0.1)
          python -m pip install --upgrade pexpect; # (3.2)
          #python -m pip install --upgrade Pillow; # (2.7.0)
          python -m pip install --upgrade pip; # (6.1.1)
          python -m pip install --upgrade pip-tools; # (6.0.3)
          #python -m pip install --upgrade pycups; # (1.9.72)
          #python -m pip install --upgrade pycurl; # (7.19.5)
          #python -m pip install --upgrade pygobject; # (3.14.0)
          #python -m pip install --upgrade PyICU; # (1.8)
          #python -m pip install --upgrade python-apt; # (0.9.3.11build1)
          #python -m pip install --upgrade python-debian; # (0.1.22)
          #python -m pip install --upgrade reportlab; # (3.1.44) .pillow .setuptools .
          python -m pip install --upgrade requests; # (2.4.3)
          #python -m pip install --upgrade screen-resolution-extra; # (2.6.3)
          python -m pip install --upgrade setuptools; # (15.2)
          python -m pip install --upgrade six; # (1.9.0)
          python -m pip install --upgrade ssh-import-id; # (4.1)
          #python -m pip install --upgrade ubuntu-drivers-common; # (2.6.3)
          #python -m pip install --upgrade ufw; # (0.34-rc-0ubuntu5)
          #python -m pip install --upgrade unattended-upgrades; # (0.1)
          python -m pip install --upgrade urllib3; # (1.9.1)
          #python -m pip install --upgrade usb-creator; # (0.2.23)
          #python -m pip install --upgrade virtualenv; # (12.0.4)
          #python -m pip install --upgrade wheel; # (0.24.0)
          #python -m pip install --upgrade xkit; # (2.6.3)

          python -m pip install --upgrade elasticsearch; #.urllib3 
          python -m pip install --upgrade jinja2; #.markupsafe
          python -m pip install --upgrade flask;  #.markupsafe .itsdangerous .Jinja2 .Werkzeug
          python -m pip install --upgrade flask-script; #.markupsafe .itsdangerous .Jinja2 .Werkzeug .flask
          python -m pip install --upgrade uwsgi;
          python -m pip install --upgrade pyparsing;

          python -m pip install --upgrade markdown;
          python -m pip install --upgrade basicauth;
          python -m pip install --upgrade oauthlib;
          python -m pip install --upgrade oauth2client; # .httplib2 .six .rsa .pyasn1 .pyasn1-modules 

          python -m pip install --upgrade paramiko; #.ecdsa .pycrypto
          
          python -m pip install --upgrade google-api-python-client; #.six .rsa .pyasn1 .simplejson .oauth2client .uritemplate .pyasn1-modules .httplib2
          python -m pip install --upgrade goslate; #.futures #BUG
          #python -m pip install --upgrade cython;
          
          #Option alternative list
          python -m pip install --upgrade freeze; #.six
          python -m pip freeze -l;

          deactivate

          chown -R ${WWW_DATA}:${WWW_DATA} /opt/venv

          #==========
          echo "#     # for USE RUNTIME VENV..."
          #==========
          echo "#     $ . /opt/venv/${project}/bin/activate";
          echo "#     $ #... operations ...#";
          echo "#     $ deactivate";
          # TESTED OK

          echo "#   Requirements PYVENV##${projet} successful";
        ;;
      esac

    done
  fi

  #==========
  echo && echo "#   Checking UWSGI##X.Y.Z";
  #==========
  vuwsgi=$(uwsgi --version |awk '{print $1}');  #RULE
  if [[ "${vuwsgi}" < "2.0.7" ]]; then
    #==========
    echo "#  install UWSGI#2.0.10 from source [OPTION]"
    echo "#  (DEACTIVATE)";
    #========== SOURCE
    [ -d /opt ] || mkdir -p /opt
    cd /opt
    curl http://uwsgi.it/install |sudo bash -s default /opt/uwsgi
    /opt/uwsgi --version
    chown ${WWW_DATA}:${WWW_DATA} /opt/uwsgi
    rm -rf uwsgi_latest_from_installer*
    chown ${WWW_DATA}:${WWW_DATA} /opt/uwsgi; #HTTP SERVER USED
    vuwsgi=$(uwsgi --version |awk '{print $1}'); 
  fi
  echo "#   Requirements UWSGI##${vuwsgi} successful";

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
    dist-upgrade - upgrade platform with jruby::gems python3::pip3
_EOF_
;;
esac

unset uid gid group pass;

exit $SCRIPT_OK
