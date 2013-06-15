#!/bin/bash
### BEGIN INIT INFO
# Provides: centrallog: mongodb
# Short-Description: DEPLOY SERVER: [STORAGESEARCH]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130615
### END INIT INFO

# Description: SERVICE CENTRALLOG: mongodb (NoSQL, INDEX, SEARCH)
# - deploy mongodb v2.4.4
#
# Requires : you need root privileges tu run this script
# Requires : JRE7 to run elasticsearch
# Requires : curl
#
# CONFIG:   [ "/etc/mongodb", "/etc/mongodb/test" ]
# BINARIES: [ "/opt/mongodb/", "/usr/share/mongodb/" ]
# LOG:      [ "/var/log/mongodb/" ]
# RUN:      [ "/var/mongodb/mongodb.pid" ]
# INIT:     [ "/etc/init.d/mongodb" ]

set -e

NAME=mongodb
DESC="mongodb Server"
DEFAULT=/etc/default/$NAME

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

cat <<-'EOF' >centralized-mongodb.getbin.sh
#!/bin/sh

[ -d "/opt/mongodb" ] || sudo mkdir -p /opt/mongodb;
[ -d "/etc/mongodb" ] || sudo mkdir -p /etc/mongodb;

SITE=http://downloads-distro.mongodb.org/

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

case $DISTRIB in
Ubuntu*|Debian*)
  echo "apt-get update";
  echo "apt-get install openjdk-7-jre";
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
  touch /etc/apt/sources.list.d/10gen.list
  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list
  sudo apt-get update
  echo 'echo "mongodb-10gen hold" | dpkg --set-selections'
  echo "sudo apt-get install mongodb-10gen=2.2.4"
  sudo apt-get install mongodb-10gen
;;
Red*Hat*)
  touch /etc/yum.repos.d/10gen.repo
  cat <<-ZEOF
[10gen]
name=10gen Repository
#32bits
#baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/i686
#64bits
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64
gpgcheck=0
enabled=1
ZEOF
  echo "yum install mongo-10gen-2.2.4 mongo-10gen-server-2.2.4"
  echo 'echo "#to pin a package" >> /etc/yum.conf'
  echo 'echo "#exclude=mongo-10gen,mongo-10gen-server" >> /etc/yum.conf'
  yum install mongo-10gen mongo-10gen-server
;;
*)
 : 
;;
esac

EOF
chmod a+x centralized-mongodb.getbin.sh

cat <<EOF >centralized-mongodb.sh
echo "view /etc/mongodb.conf"
echo "sudo service mongodb stop";
echo "sudo service mongodb start";
echo "sudo service mongodb restart";
/etc/init.d/mongodb status
/etc/init.d/mongodb force-reload
/etc/init.d/mongodb restart
EOF

cat <<EOF >centralized-mongodb.test.sh
cat <<ZEOF | mongo
db.test.save( { a: 1 } )
db.test.find()
exit
ZEOF
EOF

