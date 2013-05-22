#!/bin/sh

# RFU: READY FOR USE !
# DEPLOY CENTRALIZED SERVER : BROKER, INDEXER, STORAGESEARCH, WEBUI
# DEPLOY CENTRALIZED SERVER : SHIPPER(local), STORAGESEARCH, WEBUI

./centralized-logstash.config.sh
./centralized-broker.config.sh
./centralized-indexer.config.sh
./centralized-shipper.config.sh
./centralized-storagesearch.config.sh
./centralized-webui.config.sh

exit 0;
