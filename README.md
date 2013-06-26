## KATASCRIPT REST ReadyForUse
### service CentralLog [RFU:v0.1.0] :
  ![Screenshots](https://cacoo.com/diagrams/mTm79GTjCk8HGxsz-BE94C.png?t=1368912915182)
    
    sh/centrallog/centralized-centrallog.rfu.sh   # VM CENTRAL
    sh/centrallog/distributed-logstash.rfu.sh     # VM's DISTRIBUTED
  
### service standalone [RFU:v0.1.0] :
    
    sh/standalone/standalone-jboss.rfu.sh     # VM CENTRAL
    sh/standalone/standalone-ruby.rfu.sh      # VM CENTRAL

Depends
==========================
  - logstash [http://logstash.net] [v1.1.13]
  - redis [http://redis.io] [v2.6.14]
  - elasticsearch [http://elasticsearch.org] [v0.90.1]
  - kibana3 [http://kibana.org] [v3m2]
  - mongoDB [http://www.mongodb.org/] [v2.4.4]
  - graylog2 [http://graylog2.org] [working]
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
