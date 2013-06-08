SERVICE

Centrallog : v0.1.alpha
+ Centralized :
   + broker[Redis] => indexer[logstash] => storagesearch[elasticsearch] => webui[Kibana3]
+ Distributed :
   + shipper[logstash] => broker[Redis]

