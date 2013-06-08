SERVICE: Centrallog, version: v0.1.alpha
- desc: https://cacoo.com/diagrams/mTm79GTjCk8HGxsz,
+ rfu: "sh/centrallog/centralized-centrallog.rfu.sh",
   + node: 192.168.17.89,"vmhost00",
   + desc: {broker: [Redis], indexer: [logstash], storagesearch: [elasticsearch], webui: [Kibana3]},
+ rfu: "sh/centrallog/distributed-logstash.rfu.sh",
   + node: 192.168.17/28,"vmhost99",
   + desc: {shipper: [logstash], broker: [Redis]}




