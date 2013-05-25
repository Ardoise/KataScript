#!/bin/sh

# RFU: READY FOR USE !
# DEPLOY CENTRALIZED SERVER : BROKER, INDEXER, STORAGESEARCH, WEBUI
# DEPLOY CENTRALIZED SERVER : SHIPPER(local), STORAGESEARCH, WEBUI
#
# created by : https://github.com/Ardoise

[ -d "/opt/centrallog" ] || sudo mkdir -p /opt/centrallog;
[ -d "/opt/centrallog" ] && (
  cp stdlevel /opt/centrallog;
  cp centralized-*.rfu.sh /opt/centrallog; chmod a+x /opt/centrallog/*.sh
  cd /opt/centrallog;
  [ -s "./centralized-logstash.rfu.sh" ] || ./centralized-logstash.rfu.sh
  [ -s "./centralized-redis.rfu.sh" ] || ./centralized-redis.rfu.sh
  [ -f "./centralized-storagesearch.config.sh" ] || ./centralized-storagesearch.config.sh
  [ -f "./centralized-webui.config.sh" ] || ./centralized-webui.config.sh
)


exit 0;
