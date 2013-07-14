#!/bin/sh -e
### BEGIN INIT INFO
# Provides: RDM: vagrant
# Short-Description: DEPLOY SERVER
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130713
### END INIT INFO

# Description: SERVICE RDM: vagrant 
# - use vagrant v1.2.3
#
# Requires : you need root privileges to run this script
# Requires : virtualbox 4.2.10 to run vagrant
#
# CONFIG:   [ "/etc/vagrant", "/etc/vagrant/test" ]
# BINARIES: [ "/opt/vagrant/", "/usr/share/local/vagrant" ]
# LOG:      [ "/var/log/vagrant/" ]
# RUN:      [ "/var/vagrant/vagrant.pid" ]
# INIT:     [ "/etc/init.d/vagrant" ]
# PLUGINS:  [ "/usr/share/vagrant/bin/plugin" ]

DESCRIPTION="Vagrant Server";
NAME="vagrant";

SCRIPT_OK=0;
SCRIPT_ERROR=1;
SCRIPT_NAME=`basename $0`;
DEFAULT=/etc/default/$NAME;
cd $(dirname $0) && SCRIPT_DIR="$PWD" && cd - >/dev/null;
SH_DIR=$(dirname $SCRIPT_DIR);echo "echo SH_DIR=$SH_DIR";
platform="$(lsb_release -i -s)";
platform_version="$(lsb_release -s -r)";

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit $SCRIPT_ERROR
fi

# OWNER
[ -e "${SH_DIR}/lib/usergroup.sh" ] && . ${SH_DIR}/lib/usergroup.sh || exit 1;
uid=$NAME;gid=$NAME;group=devops;pass=$NAME;
usergroup POST;

[ -d "/etc/vagrant/test" ] || sudo mkdir -p /etc/vagrant/test;
[ -d "/opt/vagrant" ] || sudo mkdir -p /opt/vagrant;
[ -d "/var/log/vagrant" ] || sudo mkdir -p /var/log/vagrant;
[ -d "/opt/vagrant" ] && cd /opt/vagrant;

cat <<"EOF" >standalone-vagrant.getbin.sh
#!/bin/sh -e

platform="$(lsb_release -i -s)";
platform_version="$(lsb_release -s -r)";

[ -d "/opt/vagrant" ] || mkdir -p /opt/vagrant;
[ -d "/etc/vagrant/test" ] || mkdir -p /etc/vagrant/test;

SITE=http://downloads.vagrantup.com/tags/v1.2.3/

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

[ -d "/opt/vagrant" ] && cd /opt/vagrant;

Ubuntu*|Debian*)
  sudo apt-get update
  sudo apt-get install vagrant

  vagrant box add base http://files.vagrantup.com/lucid32.box
  vagrant init
  vagrant up
  vagrant ssh
  
  echo "cd ~/VirtualBox VMs"
  
;;
*)
  echo "Sorry ! for your OS $SYSTEM $DISTRIB, your contribution is WelcOme ! ardoise.gisement@gmail.com";
;;
esac


EOF
chmod a+x standalone-vagrant.getbin.sh;

cat <<"EOF" >standalone-vagrant.putconf.sh
#!/bin/sh

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

case $DISTRIB in
Ubuntu*|Debian*)
  echo "sudo useradd -r devops";
  echo "sudo chown devops: /usr/share/local/vagrant/ -R";

  [ -d "/usr/local/share/vagrant/bin" ] && (
    cd /usr/local/share/vagrant/bin;
    cat <<"ZEOF" | ./add-user.sh
a
ManagementRealm
devops
devops
devops
yes
ZEOF
  echo "Added user 'devops' to file '/usr/local/share/vagrant/standalone/configuration/mgmt-users.properties'"
  echo "Added user 'devops' to file '/usr/local/share/vagrant/domain/configuration/mgmt-users.properties'"
;;
Redhat*|Red*Hat*)
  echo "sudo useradd -r devops";
  echo "sudo chown devops: /usr/local/vagrantas/ -R";
  [ -d "/usr/local/vagrantas/bin" ] && (
    cd /usr/local/vagrantas/bin;
    cat <<"ZEOF" | ./add-user.sh
a
ManagementRealm
devops
devops
devops
yes
ZEOF
  echo "Added user 'devops' to file '/usr/local/vagrantas/standalone/configuration/mgmt-users.properties'"
  echo "Added user 'devops' to file '/usr/local/vagrantas/domain/configuration/mgmt-users.properties'"  
;;
*)
 : 
;;
esac

cat <<ZEOF vagrant-elasticsearch.yml
cluster.name: centrallog
node.name: "scrutmydocs"
network.host: ${yourIP}
path.logs: "/var/log/elasticsearch"
path.data: "/var/lib/elasticsearch"
# path.config: "/etc/elasticsearch/elasticsearch"
# If you want to check plugins before starting
plugin.mandatory: mapper-attachments, river-fs
# If you want to disable multicast
discovery.zen.ping.multicast.enabled: false
ZEOF
[ -d "/etc/elasticsearch/test" ] && cp vagrant-elasticsearch.yml /etc/elasticsearch/test/

cat <<ZEOF vagrant-iptables.sh
# Optional : Running JBoss on Port 80
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -A PREROUTING -p udp -m udp --dport 80 -j REDIRECT --to-ports 8080
ZEOF

yourIP=$(hostname -i | cut -d' ' -f1);
yourIP=${yourIP:-"127.0.0.1"};

yourDOMAIN=$(hostname -d | cut -d' ' -f1);
yourDOMAIN=${yourDOMAIN:-"domain.com"};

yourALIAS=$(hostname -s | cut -d' ' -f1);
yourALIAS=${yourALIAS:-"localhost"};

cat <<ZEOF vagrant-virtualhost-80.conf
  <VirtualHost *:80>  
    ServerAdmin admin@${yourDOMAIN}
    ServerName ${yourDOMAIN} 
    ServerAlias ${yourALIAS}.${yourDOMAIN}
    
    ProxyRequests Off  
    ProxyPreserveHost On  
    <Proxy *>  
      Order allow,deny  
      Allow from all  
    </Proxy>  
    
    # HTTP connector : DEFAULT
    ProxyPass / http://${yourIP}:8080/
    ProxyPassReverse / http://${yourIP}:8080/
    
    # AJP connector : OPTION
    # ProxyPass / ajp://${yourIP}:8009/
    # ProxyPassReverse / ajp://${yourIP}:8009/
    
    ErrorLog logs/${yourDOMAIN}-error_log  
    CustomLog logs/${yourDOMAIN}-access_log common  
    
  </VirtualHost>  
ZEOF

)
EOF
chmod a+x standalone-vagrant.putconf.sh

cat <<"EOF" >standalone-vagrant.sh
#!/bin/sh

yourIP=$(hostname -i | cut -d' ' -f1);
yourIP=${yourIP:-"127.0.0.1"};

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

case $DISTRIB in
  Ubuntu*|Debian*)
  
  cat <<"ZEOF" >etc-init.d-uvagrant.sh
#!/bin/sh
### BEGIN INIT INFO
# Provides: vagrant
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

export VAGRANT_HOME=/usr/local/share/vagrant
export PATH=$VAGRANT_HOME/bin:$PATH

case "$1" in
  start)
    echo "Starting JBoss AS 7.1.1"
    #sudo -u devops sh ${VAGRANT_HOME}/bin/standalone.sh
    ${VAGRANT_HOME}/bin/standalone.sh -Dvagrant.bind.address=@yourIP@ -Dvagrant.bind.address.management=@yourIP@&
  ;;
  stop)
    echo "Stopping JBoss AS 7.1.1"
    #sudo -u devops sh ${VAGRANT_HOME}/bin/vagrant-admin.sh --connect command=:shutdown
    ${VAGRANT_HOME}/bin/vagrant-cli.sh --connect --controller=@yourIP@:9999 command=:shutdown
  ;;
  *)
    echo "Usage: /etc/init.d/vagrant {start|stop}"
    exit 1
  ;;
esac
exit 0
ZEOF

    sed -i "s/@yourIP@/${yourIP}/g" etc-init.d-uvagrant.sh;
    sudo chmod a+x etc-init.d-uvagrant.sh
    [ -s "/etc/init.d/vagrant" ] || cp etc-init.d-uvagrant.sh /etc/init.d/vagrant
    
  ;;
  Redhat*|Red*hat*)

    cat <<"ZEOF" >etc-init.d-cvagrant.sh    
#!/bin/sh
### BEGIN INIT INFO
# Provides: vagrant
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
export VAGRANT_HOME=/usr/local/share/vagrant
export PATH=$VAGRANT_HOME/bin:$PATH

case "$1" in
  start)
    echo "Starting JBoss AS 7.1.1"
    #sudo -u vagrant sh ${VAGRANT_HOME}/bin/standalone.sh
    start-stop-daemon --start --quiet --background --chuid devops --exec ${VAGRANT_HOME}/bin/standalone.sh
  ;;
  stop)
    echo "Stopping JBoss AS 7.1.1"
    #sudo -u vagrant sh ${VAGRANT_HOME}/bin/vagrant-admin.sh --connect command=:shutdown
    start-stop-daemon --start --quiet --background --chuid devops --exec ${VAGRANT_HOME}/bin/vagrant-admin.sh -- --connect command=:shutdown
    ;;
  *)
    echo "Usage: /etc/init.d/vagrant {start|stop}"
    exit 1
  ;;
esac
exit 0
ZEOF

    sudo chmod a+x etc-init.d-cvagrant.sh
    [ -s "/etc/init.d/vagrant" ] || cp etc-init.d-cvagrant.sh /etc/init.d/vagrant
;;
esac


sudo service vagrant stop
sudo service vagrant start

EOF
chmod a+x standalone-vagrant.sh

cat <<"EOF" >standalone-vagrant.test.sh
#!/bin/sh

yourIP=$(hostname -I | cut -d' ' -f1);
yourIP=${yourIP:-"127.0.0.1"};
echo "toAdmin => http://${yourIP}:9990/console"
echo "scrutmydocs => http://${yourIP}:8080/scrutmydocs-0.2.0/"

EOF
chmod a+x standalone-vagrant.test.sh


[ -x "standalone-vagrant.getbin.sh" ] && echo "/opt/vagrant/standalone-vagrant.getbin.sh";
[ -x "standalone-vagrant.putconf.sh" ] && echo "/opt/vagrant/standalone-vagrant.putconf.sh";
[ -x "standalone-vagrant.sh" ] && echo "/opt/vagrant/standalone-vagrant.sh";
[ -x "standalone-vagrant.test.sh" ] && echo "/opt/vagrant/standalone-vagrant.test.sh";


exit 0
