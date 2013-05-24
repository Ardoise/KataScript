#!/bin/sh

cat <<EOF >centralized-redis.getbin.sh
#!/bin/sh

[ -d "/opt/redis" ] || sudo mkdir -p /opt/redis;
[ -d "/etc/redis/tmp" ] || sudo mkdir -p /etc/redis/tmp;

[ -s "redis-2.6.13.tar.gz" ] || (
curl -OL http://redis.googlecode.com/files/redis-2.6.13.tar.gz
tar -xvfz redis-2.6.13.tar.gz
)
[ -d "redis-2.6.13" ] || (
  cd redis-2.6.13
  make
  make test
  make install
  sudo cp utils/redis_init_script /etc/init.d/redis
  cp redis.conf /etc/redis/tmp/6379.conf
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

# update-rc.d redis defaults
# chkconfig redis on
# service redis start
/etc/init.d/redis --loglevel verbose

EOF
chmod a+x centralized-redis.sh

exit 0;
