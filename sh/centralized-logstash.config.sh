#!/bin/sh

./centralized-elasticsearch.config.sh
./centralized-redis.config.sh
./centralized-indexer.config.sh
./centralized-shipper.config.sh

exit 0;
