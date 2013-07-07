#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: @generic@
# Short-Description: DEPLOY SERVER: [@GENERIC@]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130707
### END INIT INFO

# Description: SERVICE CENTRALLOG: @generic@ (...)
# - deploy @generic@ v0.0.1
#
# Requires : you need root privileges tu run this script
# Requires : JRE7 to run @generic@
# Requires : curl
#
# CONFIG:   [ "/etc/@generic@", "/etc/@generic@/test" ]
# BINARIES: [ "/opt/@generic@/", "/usr/share/@generic@/" ]
# LOG:      [ "/var/log/@generic@/" ]
# RUN:      [ "/var/@generic@/@generic@.pid" ]
# INIT:     [ "/etc/init.d/@generic@" ]

SCRIPT_OK=0
SCRIPT_ERROR=1

DESCRIPTION="@GENERIC@ Server";
SCRIPT_NAME=`basename $0`
NAME=@generic@
DEFAULT=/etc/default/$NAME

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

cat <<-'EOF' >centralized-@generic@.getbin.sh
#!/bin/sh -e

[ -d "/opt/@generic@" ] || sudo mkdir -p /opt/@generic@;
[ -d "/etc/@generic@/test" ] || sudo mkdir -p /etc/@generic@/test;
[ -d "/var/lib/@generic@" ] || sudo mkdir -p /var/lib/@generic@;
[ -d "/var/log/@generic@" ] || sudo mkdir -p /var/log/@generic@;

SITE=http://downloads-distro.@generic@.org/
@GENERIC@_PACKAGE=generic-0.0.1-bin.tar.gz;

[ -f "${@GENERIC@_PACKAGE}" ] || wget --no-check-certificate $SITE/${@GENERIC@_PACKAGE};
[ -f "${@GENERIC@_PACKAGE}.asc" ] || wget --no-check-certificate $SITE/${@GENERIC@_PACKAGE}.asc;
[ -f "${@GENERIC@_PACKAGE}.md5" ] || wget --no-check-certificate $SITE/${@GENERIC@_PACKAGE}.md5;

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

case $DISTRIB in
Ubuntu*|Debian*)
  echo "apt-get update";
  echo "apt-get install openjdk-7-jre";

;;
Red*Hat*)
  echo "yum install @generic@"
;;
*)
 : 
;;
esac

EOF
chmod a+x centralized-@generic@.getbin.sh


cat <<EOF >centralized-@generic@.putconf.sh
#!/bin/sh -e

cat <<CEOF >@generic@.conf
# @generic@.conf
CEOF
chmod 644 @generic@.conf
[ -d "/etc/@generic@/test" ] || sudo mkdir -p /etc/@generic@/test;
[ -d "/etc/@generic@/test" ] && mv @generic@.conf /etc/@generic@/test/;

EOF


cat <<EOF >centralized-@generic@.sh
echo "view /etc/@generic@/test/@generic@.conf"
echo "sudo service @generic@ status";
echo "sudo service @generic@ reload";
echo "sudo service @generic@ stop";
echo "sudo service @generic@ start";
echo "sudo service @generic@ restart";
EOF


cat <<'EOF' >centralized-@generic@.test.sh
#!/bin/sh -e

cat <<'MEOF' | @generic@

exit
MEOF

yourIP=$(hostname -I | cut -d' ' -f1);
yourIP=${yourIP:-localhost};


EOF
chmod +x centralized-@generic@.test.sh


echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-@generic@ : get binaries ..."
sh centralized-@generic@.getbin.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-@generic@ : get binaries [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-@generic@ : put config ..."
sh centralized-@generic@.putconf.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-@generic@ : put config [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-@generic@ : start ..."
sh centralized-@generic@.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-@generic@ : start [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-@generic@ : test ..."
sh centralized-@generic@.test.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-@generic@ : test [ OK ]"

exit 0
