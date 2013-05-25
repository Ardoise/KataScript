#!/bin/sh

#
# created by : https://github.com/Ardoise

cat <<EOF >centralized-redis.getbin.sh
#!/bin/sh

[ -d "/opt/redis" ] || sudo mkdir -p /opt/redis;
[ -d "/etc/redis/tmp" ] || sudo mkdir -p /etc/redis/tmp;

[ -s "redis-2.6.13.tar.gz" ] || curl -OL http://redis.googlecode.com/files/redis-2.6.13.tar.gz
[ -d "redis-2.6.13" ] || (
  tar xvfz redis-2.6.13.tar.gz
  cd redis-2.6.13
  make
  sudo make install
  make test
  sudo cp utils/redis_init_script /etc/init.d/redis
  sudo cp redis.conf /etc/redis/tmp/6379.conf
  [ -f "/etc/redis/6379.conf" ] || sudo cp redis.conf /etc/redis/6379.conf
)
EOF
chmod a+x centralized-redis.getbin.sh

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

exit 0;
