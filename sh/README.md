SERVICE: Centrallog, version: v0.1.alpha
- DESC: https://cacoo.com/diagrams/mTm79GTjCk8HGxsz,
+ RFU: "sh/centrallog/centralized-centrallog.rfu.sh",
   + Node: "VM CENTRAL",
   + Desc: {broker: [Redis], indexer: [logstash], storagesearch: [elasticsearch], webui: [Kibana3]},
+ RFU: "sh/centrallog/distributed-logstash.rfu.sh",
   + Node: "VM's DISTRIBUTED",
   + Desc: {shipper: [logstash], broker: [Redis]}




