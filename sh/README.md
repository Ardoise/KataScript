SERVICE:1,{ 
- name: "Centrallog", 
- version: "v0.1.0",
- desc: "https://cacoo.com/diagrams/mTm79GTjCk8HGxsz",
+ rfu: "sh/centrallog/centralized-centrallog.rfu.sh",
   + type: [vm: "CENTRALIZED"],
   + node: 192.168.17.89,"vmhost00",
   + desc: {broker: [Redis], indexer: [logstash,flume], storagesearch: [elasticsearch], webui: [Kibana3] },
+ rfu: "sh/centrallog/distributed-logstash.rfu.sh",
   + type: [vm: "DISTRIBUTED"],
   + node: 192.168.17/28,"vmhost99",
   + desc: {shipper: [logstash], shipper: [flume]}
}

SERVICE:2,{
- name: "JBossAS", 
- version: "v0.1.0",
- desc: "standalone",
+ rfu: "sh/standalone/standalone-jboss.rfu.sh",
   + type: vm,
   + node: 192.168.17.89,"vmhost00",
   + desc: "serveur Java JBoss"
}

SERVICE:3,{
- name: "RubyOnRail", 
- version: "v2.0.0",
- desc: "Ruby on Rail",
+ rfu: "sh/standalone/standalone-ruby.rfu.sh",
   + type: vm,
   + node: 192.168.17.89,"vmhost00",
   + desc: "server Ruby on Rail"
}
