#!/bin/sh

cat <<EOF >centralized-redis.getbin.sh
#!/bin/sh
[ -s "redis-2.6.13.tar.gz" ] || (
curl -OL http://redis.googlecode.com/files/redis-2.6.13.tar.gz
tar -xvfz redis-2.6.13.tar.gz
)
[ -d "redis-2.6.13" ] || (
cd redis-2.6.13
make
make test
)
EOF
chmod a+x centralized-redis.getbin.sh

cat <<"EOF" >centralized-redis.test.sh
#!/bin/sh
[ -d "redis-2.6.13" ] && (
  cd redis-2.6.13
  cat <<ZEOF | src/redis-cli
set foo bar
get foo
ZEOF
)
EOF
chmod a+x centralized-redis.test.sh

cat <<EOF >centralized-redis.sh
#!/bin/sh
[ -d "redis-2.6.13" ] && (
cd redis-2.6.13
src/redis-server --loglevel verbose
)
EOF
chmod a+x centralized-redis.sh

exit 0;
