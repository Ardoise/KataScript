#!/bin/sh

# RFU: READY FOR USE !
# DEPLOY CENTRALIZED SERVER : BROKER, INDEXER, STORAGESEARCH, WEBUI
# DEPLOY CENTRALIZED SERVER : SHIPPER(local), STORAGESEARCH, WEBUI

./centralized-logstash.rfu.sh
./centralized-redis.rfu.sh
#./centralized-indexer.config.sh DEPRECATED
#./centralized-shipper.config.sh DEPRECATED
./centralized-storagesearch.config.sh
./centralized-webui.config.sh

exit 0;
