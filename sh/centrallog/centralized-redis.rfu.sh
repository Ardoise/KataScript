#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: redis
# Short-Description: DEPLOY SERVER: [BROKER]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130531
### END INIT INFO

# Description: SERVICE CENTRALLOG: REDIS (NoSQL, Broker)
# - deploy redis v2.6.14
#
# Requires : you need root privileges tu run this script
# Requires : curl, gcc
#
# CONFIG:   [ "/etc/redis", "/etc/redis/test" ]
# BINARIES: [ "/opt/redis/", "/usr/local/bin/redis-server", "/usr/local/bin/redis-cli" ]
# LOG:      [ "/var/log/redis/" ]
# RUN:      [ "/var/run/redis.pid" ]
# INIT:     [ "/etc/init.d/redis" ]

SCRIPT_NAME=`basename $0`
NAME=redis
DESC="redis Server"
DEFAULT=/etc/default/$NAME

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

cat <<EOF >centralized-redis.getbin.sh
#!/bin/sh

[ -d "/opt/redis" ] || sudo mkdir -p /opt/redis;
[ -d "/etc/redis/test" ] || sudo mkdir -p /etc/redis/test;
[ -d "/val/log/redis" ] || sudo mkdir -p /var/log/redis;

[ -s "redis-2.6.14.tar.gz" ] || curl -OL http://redis.googlecode.com/files/redis-2.6.14.tar.gz
[ -d "redis-2.6.14" ] || (
  tar xvfz redis-2.6.14.tar.gz
  cd redis-2.6.14
  sudo make
  sudo make install
  sudo make test
  # sudo cp utils/redis_init_script /etc/init.d/redis   # BUG redis_server start
  sudo cp redis.conf /etc/redis/test/6379.conf
  [ -f "/etc/redis/6379.conf" ] || sudo cp redis.conf /etc/redis/6379.conf
  
  # TO TEST
  # cd utils
  # ./install_server
)
EOF
chmod a+x centralized-redis.getbin.sh

[ -d "/etc/redis/test" ] || sudo mkdir -p /etc/redis/test;
cat <<"EOF" >centralized-redis.putconf.sh

cat <<"ZEOF" >>6379.conf
# debug verbose notice warning
loglevel debug
# stdout myfile
logfile /var/log/redis/redis.log
ZEOF
cat 6379.conf > /etc/redis/test/6379.add.conf

cat <<"ZEOF" >redis_init_script
#!/bin/sh
#
# Simple Redis init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.

REDISPORT=6379
EXEC=/usr/local/bin/redis-server
CLIEXEC=/usr/local/bin/redis-cli

PIDFILE=/var/run/redis_${REDISPORT}.pid
CONF="/etc/redis/${REDISPORT}.conf"

case "$1" in
    start)
        if [ -f $PIDFILE ]
        then
                echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $PIDFILE exists, process is already running or crashed"
        else
                echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Starting Redis server..."
                $EXEC $CONF &
        fi
        ;;
    stop)
        if [ ! -f $PIDFILE ]
        then
                echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $PIDFILE does not exist, process is not running"
        else
                PID=$(cat $PIDFILE)
                echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Stopping ..."
                $CLIEXEC -p $REDISPORT shutdown
                while [ -x /proc/${PID} ]
                do
                    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Redis stopped"
        fi
        ;;
    *)
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Please use start or stop as first argument"
        ;;
esac
ZEOF
sudo cp redis_init_script /etc/init.d/redis
chmod a+x /etc/init.d/redis

EOF


cat <<"EOF" >centralized-redis.test.sh
#!/bin/sh

cat <<ZEOF | redis-cli
set foo bar
get foo
ZEOF

EOF
chmod a+x centralized-redis.test.sh

cat <<EOF >centralized-redis.sh
#!/bin/sh

# /etc/init.d/redis start
# update-rc.d redis defaults
# chkconfig redis on
# service redis stop
service redis start

EOF
chmod a+x centralized-redis.sh


echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-redis : get binaries ..."
sh centralized-redis.getbin.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-redis : get binaries [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-redis : put config ..."
sh centralized-redis.putconf.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-redis : put config [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-redis : start ..."
sh centralized-redis.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-redis : start [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-redis : test ..."
sh centralized-redis.test.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-redis : test [ OK ]"

exit 0;

