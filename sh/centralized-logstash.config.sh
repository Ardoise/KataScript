#!/bin/sh

# DEPLOY CENTRALIZED SERVER : BROKER, INDEXER, SHIPPER, STORAGESEARCH, WEBUI
. ./stdlevel

cat <<EOF >centralized-logstash.getbin.sh
curl -O http://logstash.objects.dreamhost.com/release/logstash-1.1.12-flatjar.jar
EOF
chmod a+x centralized-logstash.getbin.sh


./centralized-broker.config.sh
./centralized-indexer.config.sh
./centralized-shipper.config.sh
./centralized-storagesearch.config.sh
./centralized-webui.config.sh

exit 0;
