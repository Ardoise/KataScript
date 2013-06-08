#!/bin/sh
### BEGIN INIT INFO
# Provides: carroussellog: jboss
# Short-Description: DEPLOY SERVER: [STORAGESEARCH]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130608
### END INIT INFO

# Description: SERVICE carroussellog: jboss (NoSQL, INDEX, SEARCH)
# - use jboss v0.90.0
# - use shipper fs                        plugin
# - use webui jetty                       plugin
#
# Requires : you need root privileges tu run this script
# Requires : JRE7 to run jboss
# Requires : curl
#
# CONFIG:   [ "/etc/jboss", "/etc/jboss/test" ]
# BINARIES: [ "/opt/jboss/", "/usr/share/local/jboss" ]
# LOG:      [ "/var/log/jboss/" ]
# RUN:      [ "/var/jboss/jboss.pid" ]
# INIT:     [ "/etc/init.d/jboss" ]
# PLUGINS:  [ "/usr/share/jboss/bin/plugin" ]

set -e

NAME=jboss
DESC="JBoss Server"
DEFAULT=/etc/default/$NAME

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

[ -d "/etc/jboss" ] || sudo mkdir -p /etc/jboss;
[ -d "/opt/jboss" ] || sudo mkdir -p /opt/jboss;

cd /opt/jboss;

cat <<"EOF" >standalone-jboss.getbin.sh
#!/bin/sh

[ -d "/opt/jboss" ] || sudo mkdir -p /opt/jboss;
[ -d "/etc/jboss" ] || sudo mkdir -p /etc/jboss;

SITE=http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

case $DISTRIB in
Ubuntu*|Debian*)
  [ -d "/opt/jboss" ] && cd /opt/jboss;
  echo "sudo apt-get update"
  echo "sudo apt-get install openjdk-7-jdk wget curl -y"
  ES_PACKAGE=jboss-as-7.1.1.Final.tar.gz;
  ES_DIR=${ES_PACKAGE%%.tar.gz}
  if [ ! -d "$ES_DIR" ] ; then
    wget --no-check-certificate $SITE/$ES_PACKAGE;
    tar xvfz $ES_PACKAGE;
    # sudo tar -zxvf $ES_PACKAGE -C /opt/jboss/
    sudo mv $ES_DIR/* /usr/local/share/jboss/;
    echo "adduser devops"
    echo "chown -R devops /usr/local/share/jboss"
    echo "su - devops"    
  fi
;;
Redhat*|Red*hat*)
  echo "Sorry ! for your OS $SYSTEM $DISTRIB, your contribution is WelcOme ! ardoise.gisement@gmail.com";
;;
*)
  echo "Sorry ! for your OS $SYSTEM $DISTRIB, your contribution is WelcOme ! ardoise.gisement@gmail.com";
;;
esac
EOF
chmod a+x standalone-jboss.getbin.sh;

cat <<"EOF" >standalone-jboss.putconf.sh
#!/bin/sh

echo "sudo useradd -r devops";
echo "sudo chown devops: /usr/share/local/jboss/ -R";

[ -d "/usr/local/share/jboss/bin" ] && (
  cd /usr/local/share/jboss/bin;
  cat <<ZEOF | ./add-user.sh
a
ManagementRealm
devops
devops
devops
yes
ZEOF

echo "Added user 'devops' to file '/usr/local/share/jboss/standalone/configuration/mgmt-users.properties'"
echo "Added user 'devops' to file '/usr/local/share/jboss/domain/configuration/mgmt-users.properties'"
)
EOF
chmod a+x standalone-jboss.putconf.sh

cat <<"EOF" >standalone-jboss.sh
#!/bin/sh

yourIP=$(hostname -I | cut -d' ' -f1);
yourIP=${yourIP:-"127.0.0.1"};

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

case $DISTRIB in
  Ubuntu*|Debian*)
  
  cat <<"ZEOF" >etc-init.d-ujboss.sh
#!/bin/sh
### BEGIN INIT INFO
# Provides: jboss
# Required-Start: $local_fs $remote_fs $network $syslog
# Required-Stop: $local_fs $remote_fs $network $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start/Stop JBoss AS v7.1.1
### END INIT INFO
#
#source some script files in order to set and export environmental variables
#as well as add the appropriate executables to $PATH

export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

export JBOSS_HOME=/usr/local/share/jboss
export PATH=$JBOSS_HOME/bin:$PATH

case "$1" in
  start)
    echo "Starting JBoss AS 7.1.1"
    #sudo -u devops sh ${JBOSS_HOME}/bin/standalone.sh
    ${JBOSS_HOME}/bin/standalone.sh -Djboss.bind.address=${yourIP} -Djboss.bind.address.management=${yourIP}&
  ;;
  stop)
    echo "Stopping JBoss AS 7.1.1"
    #sudo -u devops sh ${JBOSS_HOME}/bin/jboss-admin.sh --connect command=:shutdown
    ${JBOSS_HOME}/bin/jboss-cli.sh --connect --controller=${yourIP}:9999 command=:shutdown
  ;;
  *)
    echo "Usage: /etc/init.d/jboss {start|stop}"
    exit 1
  ;;
esac
exit 0
ZEOF

    sudo chmod a+x etc-init.d-ujboss.sh
    [ -s "/etc/init.d/jboss" ] || cp etc-init.d-ujboss.sh /etc/init.d/jboss
    
  ;;
  Redhat*|Red*hat*)

    cat <<"ZEOF" >etc-init.d-cjboss.sh    
#!/bin/sh
### BEGIN INIT INFO
# Provides: jboss
# Required-Start: $local_fs $remote_fs $network $syslog
# Required-Stop: $local_fs $remote_fs $network $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start/Stop JBoss AS v7.1.1
### END INIT INFO
#
#source some script files in order to set and export environmental variables
#as well as add the appropriate executables to $PATH

export JAVA_HOME=/usr/lib/jvm/java-7-oracle
export PATH=$JAVA_HOME/bin:$PATH
export JBOSS_HOME=/usr/local/share/jboss
export PATH=$JBOSS_HOME/bin:$PATH

case "$1" in
  start)
    echo "Starting JBoss AS 7.1.1"
    #sudo -u jboss sh ${JBOSS_HOME}/bin/standalone.sh
    start-stop-daemon --start --quiet --background --chuid devops --exec ${JBOSS_HOME}/bin/standalone.sh
  ;;
  stop)
    echo "Stopping JBoss AS 7.1.1"
    #sudo -u jboss sh ${JBOSS_HOME}/bin/jboss-admin.sh --connect command=:shutdown
    start-stop-daemon --start --quiet --background --chuid devops --exec ${JBOSS_HOME}/bin/jboss-admin.sh -- --connect command=:shutdown
    ;;
  *)
    echo "Usage: /etc/init.d/jboss {start|stop}"
    exit 1
  ;;
esac
exit 0
ZEOF

    sudo chmod a+x etc-init.d-cjboss.sh
    [ -s "/etc/init.d/jboss" ] || cp etc-init.d-cjboss.sh /etc/init.d/jboss
;;
esac


sudo service jboss stop
sudo service jboss start

EOF
chmod a+x standalone-jboss.sh

cat <<"EOF" >standalone-jboss.test.sh
#!/bin/sh

yourIP=$(hostname -I | cut -d' ' -f1);
yourIP=${yourIP:-"127.0.0.1"};
echo "toDeploy => http://${yourIP}:8080/"
echo "toAdmin => http://${yourIP}:9990/console"

EOF
chmod a+x standalone-jboss.test.sh


[ -x "standalone-jboss.getbin.sh" ] && echo "/opt/jboss/standalone-jboss.getbin.sh";
[ -x "standalone-jboss.putconf.sh" ] && echo "/opt/jboss/standalone-jboss.putconf.sh";
[ -x "standalone-jboss.sh" ] && echo "/opt/jboss/standalone-jboss.sh";
[ -x "standalone-jboss.test.sh" ] && echo "/opt/jboss/standalone-jboss.test.sh";


exit 0
