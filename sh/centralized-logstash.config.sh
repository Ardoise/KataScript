#!/bin/sh

./centralized-broker.config.sh
./centralized-indexer.config.sh
./centralized-shipper.config.sh
./centralized-storagesearch.config.sh
./centralized-webui.config.sh
./centralized-system.config.sh

exit 0;
