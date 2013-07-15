## KATASCRIPT REST ReadyForUse
### service CentralLog :
  ![Screenshots](https://cacoo.com/diagrams/mTm79GTjCk8HGxsz-BE94C.png?t=1368912915182)
    
    sh/centrallog/centralized-centrallog.rfu.sh   # VM CENTRAL        [RFU:v0.1.0]
    sh/centrallog/distributed-logstash.rfu.sh     # VM's DISTRIBUTED  [RFU:v0.1.0]
    sh/centrallog/distributed-flume.rfu.sh        # VM's DISTRIBUTED  [RFU:v0.1.0]
    
    sh/json/centrallog.json                       # STATEMENT CONTEXT [RFU:v0.1.1-alpha]
    sh/centrallog/<context>-<component>.tmpl.sh   # COMPONENT CONTEXT [RFU:v0.1.1-alpha]
     Commandes :
      check         - check centrallog::<component>
      install       - install centrallog::<component>
      reload        - reload config centrallog::<component>
      remove        - remove centrallog::<component>
      start         - start centrallog::<component>
      status        - status centrallog::<component>
      stop          - stop centrallog::<component>
      upgrade       - upgrade centrallog::<component>
      dist-upgrade  - upgrade distrib platform jruby::gems
  
### service standalone :
    
    sh/standalone/standalone-jboss.rfu.sh     # VM CENTRAL  [RFU:v0.1.0]
    sh/standalone/standalone-ruby.rfu.sh      # VM CENTRAL  [RFU:v0.1.0]

Depends
==========================
  - logstash [http://logstash.net] [v1.1.13]
  - redis [http://redis.io] [v2.6.14]
  - elasticsearch [http://elasticsearch.org] [v0.90.2]
  - kibana3 [http://kibana.org] [v3m2]
  - mongoDB [http://www.mongodb.org/] [v2.4.5]
  - graylog2 [http://graylog2.org] [v0.0.0][working]
  - flume [http://flume.apache.org] [v1.4.0][working]
  - JBossAS [http://download.jboss.org] [v7.1.1]

Objectifs : + vs - : Practice 
=============================
  - Benchmarks  (time faster)
  - Power       (volume)
  - Lean        (CPU,RAM)
  - Rest        (http+html+uri)
  
Kata Script REST
================
  - JavaScript ... : js/\service\>/indexKata.js
  - Shell ........... : sh/\<service\>/indexKata.sh
  - Python ........ : py/\<service\>/indexKata.py
  - Ruby ........... : rb/\<service\>/indexKata.rb
  - JSON ........... : json, json_event, txt
  - StyleGuide
    - https://code.google.com/p/google-styleguide/
    - http://google-styleguide.googlecode.com/svn/trunk/javascriptguide.xml
    - http://google-styleguide.googlecode.com/svn/trunk/htmlcssguide.xml
    - http://google-styleguide.googlecode.com/svn/trunk/shell.xml
    - http://google-styleguide.googlecode.com/svn/trunk/pyguide.html
    - http://google-styleguide.googlecode.com/svn/trunk/xmlstyle.html
