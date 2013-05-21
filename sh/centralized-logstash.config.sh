#!/bin/sh

# DEPLOY CENTRALIZED SERVER : BROKER, INDEXER, SHIPPER, STORAGESEARCH, WEBUI
. ./stdlevel

./centralized-broker.config.sh
./centralized-indexer.config.sh
./centralized-shipper.config.sh
./centralized-storagesearch.config.sh
./centralized-webui.config.sh

exit 0;
