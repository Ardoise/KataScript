#!/bin/sh

# DEPLOY CENTRALIZED SERVER : BROKER
. ./stdlevel

cat <<EOF >centralized-redis.getbin.sh
# http://redis.io/download
curl -O http://redis.googlecode.com/files/redis-2.6.13.tar.gz
tar -xzf redis-2.6.13.tar.gz
cd redis-2.6.13
make
make test
EOF
chmod a+x centralized-redis.getbin.sh

cat <<EOF >centralized-redis.sh
cd redis-2.6.13
src/redis-server --loglevel verbose
EOF
chmod a+x centralized-redis.sh

cat <<EOF >centralized-redis.test.sh
cd redis-2.6.13
cat <<ZEOF | src/redis-cli
set foo bar
get foo
exit
ZEOF
EOF
chmod a+x centralized-redis.test.sh


exit 0;
