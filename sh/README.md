SERVICE

Centrallog : v0.1.
- https://cacoo.com/diagrams/mTm79GTjCk8HGxsz
+ Centralized :
   + broker: [Redis] => indexer: [logstash] => storagesearch: [elasticsearch] => webui: [Kibana3]
+ Distributed :
   + shipper: [logstash] => broker: [Redis]

