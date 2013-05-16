#!bin/bash

cat <<EOF >centralized-redis.sh
src/redis-server --loglevel verbose
EOF

exit 0;
