#!/bin/sh

# DEPLOY CENTRALIZED SERVER : BROKER, INDEXER, SHIPPER, STORAGESEARCH, WEBUI

./centralized-broker.config.sh
./centralized-indexer.config.sh
./centralized-shipper.config.sh
./centralized-storagesearch.config.sh
./centralized-webui.config.sh
./centralized-system.config.sh

exit 0;
