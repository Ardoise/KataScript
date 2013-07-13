#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: xgenericx
# Short-Description: DEPLOY SERVER: [XGENERICX]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130713
### END INIT INFO

# Description: SERVICE CENTRALLOG: xgenericx (...)
# - deploy xgenericx v0.0.0
#
# Requires : you need root privileges tu run this script
# Requires : curl wget make build-essential zlib1g-dev libssl-dev git-core
#
# CONFIG:   [ "/etc/xgenericx", "/etc/xgenericx/test" ]
# BINARIES: [ "/opt/xgenericx/", "/usr/share/xgenericx/" ]
# LOG:      [ "/var/log/xgenericx/" ]
# RUN:      [ "/var/xgenericx/xgenericx.pid" ]
# INIT:     [ "/etc/init.d/xgenericx" ]

# HOW to Use this script : BUILD a new component <toto>
# sed -e '/generic/s/xgenericx/logstash/g' -e '/generic/s/XGENERICX/LOGSTASH/g' > centralized-logstash.rfu.sh
# sed -e '/generic/s/xgenericx/redis/g' -e '/generic/s/XGENERICX/REDIS/g' > centralized-redis.rfu.sh
# sed -e '/generic/s/xgenericx/elasticsearch/g' -e '/generic/s/XGENERICX/ELASTICSEARCH/g' > centralized-elasticsearch.rfu.sh
# sed -e '/generic/s/xgenericx/mongodb/g' -e '/generic/s/XGENERICX/MONGODB/g' > centralized-mongodb.rfu.sh
# sed -e '/generic/s/xgenericx/kibana/g' -e '/generic/s/XGENERICX/KIBANA/g' > centralized-kibana.rfu.sh
# sed -e '/generic/s/xgenericx/flume/g' -e '/generic/s/XGENERICX/FLUME/g' > centralized-flume.rfu.sh

SCRIPT_OK=0
SCRIPT_ERROR=1

DESCRIPTION="XGENERICX Server";
SCRIPT_NAME=`basename $0`
NAME=xgenericx
DEFAULT=/etc/default/$NAME

unset groups gid uid pass
groups=admin;
gid=${gid:-devops};
uid=${uid:-devops};
pass=${pass:-devops};

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit $SCRIPT_ERROR
fi

# SUDO CHROOT
sudo groupadd -r $groups || true;
sudo sed -i -e "/Defaults\s\+env_reset/a Defaults\texempt_group=$groups" /etc/sudoers;

case "$platform" in
Ubuntu)  
  sudo sed -i -e "s/%$groups ALL=(ALL) ALL/%$groups ALL=(ALL) NOPASSWD:ALL/g" /etc/sudoers;
;;
Debian)
  sudo sed -i -e 's/%sudo ALL=(ALL) ALL/%sudo ALL=(ALL) NOPASSWD:ALL/g' /etc/sudoers
;;
Red*Hat*)
  :
;;
*)
  :
;;
esac

case "$platform" in
Ubuntu|Debian)
  sudo groupadd -r $gid || true;
  sudo useradd --gid $gid --groups $groups --password $pass $uid || true;
  sudo usermod -a -G $groups $uid || true;
  
  sudo mkdir -p /opt/centrallog || true; 
  sudo chown -R $uid:$gid /opt/centrallog || true
;;
Red*Hat*)
  :
;;
*)
  : 
;;
esac

cat <<-'EOF' >centralized-xgenericx.getbin.sh
#!/bin/sh -e

platform="$(lsb_release -i -s)";
platform_version="$(lsb_release -s -r)";

unset groups gid uid pass
groups=devops;
gid=${gid:-xgenericx};
uid=${uid:-xgenericx};
pass=${pass:-xgenericx};

XGENERICX_VER="0.0.0"
SITE=http://downloads-distro.xgenericx.org/
XGENERICX_PACKAGE=xgenericx-${XGENERICX_VER}-bin.tar.gz;

# USERS
case "$platform" in
Ubuntu|Debian)
  sudo groupadd -r $gid || true;
  sudo useradd --gid $gid --groups $groups --password $pass $uid || true;
  sudo usermod -a -G $groups $uid || true;
;;
Red*Hat*)
  :
;;
*)
  : 
;;
esac

sudo mkdir -p /opt/xgenericx || true; sudo chown -R $uid:$gid /opt/xgenericx || true
sudo mkdir -p /etc/xgenericx/test || true; sudo chown -R $uid:$gid /etc/xgenericx/ || true
sudo mkdir -p /var/lib/xgenericx || true; sudo chown -R $uid:$gid /var/lib/xgenericx || true
sudo mkdir -p /var/log/xgenericx || true; sudo chown -R $uid:$gid /var/log/xgenericx || true

[ -f "${XGENERICX_PACKAGE}" ] || wget --no-check-certificate $SITE/${XGENERICX_PACKAGE};
[ -f "${XGENERICX_PACKAGE}.asc" ] || wget --no-check-certificate $SITE/${XGENERICX_PACKAGE}.asc;
[ -f "${XGENERICX_PACKAGE}.md5" ] || wget --no-check-certificate $SITE/${XGENERICX_PACKAGE}.md5;

# LIBRAIRIES
case "$platform" in
Ubuntu)  
  echo "sudo apt-get update";
  echo "sudo apt-get -y install curl wget make build-essential \
    zlib1g-dev libssl-dev git-core libreadline-dev";
  echo "sudo apt-get -y install xgenericx"
  sudo apt-get update;
  sudo apt-get -y install curl wget make build-essential \
    zlib1g-dev libssl-dev git-core libreadline-dev;
  sudo apt-get -y install xgenericx;
;;
Debian)  
  echo "sudo apt-get update";
  echo "sudo apt-get -y install curl wget make build-essential \
    zlib1g-dev libssl-dev git-core libreadline5-dev";
  echo "sudo apt-get -y install xgenericx";
  sudo apt-get update;
  sudo apt-get -y install curl wget make build-essential \
    zlib1g-dev libssl-dev git-core libreadline5-dev;
  sudo apt-get -y install xgenericx;
;;
Red*Hat*)
  echo "sudo yum install openjdk-7-jre curl wget git"
  echo "sudo yum install xgenericx"
;;
*)
  : 
;;
esac

# PURGE
case "$platform" in
Ubuntu|Debian)
  echo "sudo apt-get -y autoremove";
  echo "sudo apt-get -y clean";
  # Option
  echo "apt-get -y remove build-essential make git-core"
  # rm -f /home/${account}/{*.bak,*.sh~}
;;
Red*Hat*)
  :
;;
*)
  : 
;;
esac

EOF
chmod a+x centralized-xgenericx.getbin.sh


cat <<EOF >centralized-xgenericx.putconf.sh
#!/bin/sh -e

cat <<CEOF >xgenericx.conf
# xgenericx.conf
CEOF
chmod 644 xgenericx.conf
[ -d "/etc/xgenericx/test" ] || mkdir -p /etc/xgenericx/test;
[ -d "/etc/xgenericx/test" ] && mv xgenericx.conf /etc/xgenericx/test/;

EOF


cat <<EOF >centralized-xgenericx.sh
echo "view /etc/xgenericx/test/xgenericx.conf"
echo "sudo service xgenericx status";
echo "sudo service xgenericx reload";
echo "sudo service xgenericx stop";
echo "sudo service xgenericx start";
echo "sudo service xgenericx restart";
EOF


cat <<'EOF' >centralized-xgenericx.test.sh
#!/bin/sh -e

cat <<'MEOF' | xgenericx

exit
MEOF

yourIP=$(hostname -I | cut -d' ' -f1);
yourIP=${yourIP:-localhost};


EOF
chmod +x centralized-xgenericx.test.sh


echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-xgenericx : get binaries ..."
sh centralized-xgenericx.getbin.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-xgenericx : get binaries [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-xgenericx : put config ..."
sh centralized-xgenericx.putconf.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-xgenericx : put config [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-xgenericx : start ..."
sh centralized-xgenericx.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-xgenericx : start [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-xgenericx : test ..."
sh centralized-xgenericx.test.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-xgenericx : test [ OK ]"

exit $SCRIPT_OK
