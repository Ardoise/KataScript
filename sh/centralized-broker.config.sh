#!/bin/sh

. stdlevel

cat <<EOF >centralized-redis.getbin.sh
# http://redis.io/download
curl -O http://redis.googlecode.com/files/redis-2.6.13.tar.gz
tar -xvfz redis-2.6.13.tar.gz
cd redis-2.6.13
make
make test
EOF
chmod a+x centralized-redis.getbin.sh

cat <<EOF >centralized-redis.cli.sh
src/redis-cli
echo "usage : set foo bar"
echo "usage : get foo"
EOF
chmod a+x centralized-redis.cli.sh

cat <<EOF >centralized-redis.sh
src/redis-server --loglevel verbose
EOF
chmod a+x centralized-redis.sh

exit 0;
