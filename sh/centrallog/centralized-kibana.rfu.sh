#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: kibana3
# Short-Description: DEPLOY SERVER: [ANALYSE, WEBUI]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130531
### END INIT INFO

# Description: SERVICE CENTRALLOG: ANALYSE LOG
# - deploy kibana v3
#
# Requires : you need root privileges tu run this script
# Requires : Apache2 to run Kibana3
# Requires : curl
#
# CONFIG: [ "/etc/kibana", "/etc/kibana/test" ]
# BINARIES: [ "/opt/kibana/" ]
# LOG:      [ "/var/log/kibana/" ]
# RUN:      [ "/var/run/kibana.pid" ]
# INIT:     [ "/etc/init.d/kibana" ]

DESC="Kibana Server";
NAME="kibana";

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


cat <<EOF >centralized-kibana.getbin.sh
#!/bin/sh

[ -d "/opt/kibana" ] || sudo mkdir -p /opt/kibana;
[ -d "/etc/kibana/test" ] || sudo mkdir -p /etc/kibana/test;
[ -d "/var/log/kibana" ] || sudo mkdir -p /var/log/kibana;
[ -d "/var/lib/kibana" ] || sudo mkdir -p /var/lib/kibana;

[ -d "/opt/kibana" ]  && (
  # KIBANA1
  #  git clone --branch=kibana-ruby https://github.com/rashidkpc/Kibana.git
  #  mv Kibana kibana
  #  cd kibana
  #  sudo bundle install
  #  sudo ruby kibana.rb
  
  #  # require : RubyGems
  #  # http://production.cf.rubygems.org/rubygems/rubygems-2.0.3.zip
  #  sudo gem update --system
  #  sudo gem install rubygems-update
  #  sudo update_rubygems
  
  # KIBANA3
  cd /opt/kibana
  [ -s "master.tar.gz" ] || curl -OL https://github.com/elasticsearch/kibana/archive/master.tar.gz
  [ -d "kibana-master" ] || tar xvfz master.tar.gz;  
)
EOF
chmod a+x centralized-kibana.getbin.sh

cat <<"EOF" >centralized-kibana.putconf.sh
#!/bin/sh
# gem update --system

yourIP=$(hostname -I | cut -d' ' -f1);
  
cat <<ZEOF >config.add.js
  var config = new Settings(
    {
    elasticsearch: 'http://${yourIP:=127.0.0.1}:9200',
    kibana_index: "kibana-int", 
    modules: ['histogram','map','pie','table','stringquery','sort',
              'timepicker','text','fields','hits','dashcontrol',
              'column','derivequeries','trends'],
    }
  );
ZEOF
[ -d "/etc/kibana/test" ] && sudo cp config.add.js /etc/kibana/test/config.js ;
[ -e "/opt/kibana/kibana-master/config.js" ] && sudo mv /opt/kibana/kibana-master/config.js /opt/kibana/kibana-master/config.js.ORI  
[ -d "/var/www" ] && (
  sudo cp config.add.js /etc/kibana/config.js ;
  sudo cp -Rp /opt/kibana/kibana-master /var/www/kibana ;
  sudo cp config.add.js /var/www/kibana/config.js ;
)
EOF

cat <<EOF >centralized-kibana.sh
#!/bin/sh
# sudo service kibana start
EOF
chmod a+x centralized-kibana.sh

cat <<"EOF" >centralized-kibana.test.sh
#!/bin/sh
yourIP=$(hostname -I | cut -d' ' -f1);
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: http://${yourIP:=127.0.0.1}/kibana/#/dashboard"
EOF
chmod a+x centralized-kibana.test.sh

# REST : CHILD
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : get binaries ..."
sh centralized-kibana.getbin.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : get binaries [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : put config ..."
sh centralized-kibana.putconf.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : put config [ OK ]"
# echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : start service ..."
# sh centralized-kibana.sh;
# echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : start service [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : test service ..."
sh centralized-kibana.test.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : test service [ OK ]"

exit 0
