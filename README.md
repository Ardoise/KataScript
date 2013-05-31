KATASCRIPT REST ReadyForUse
===================================
  service [CentralLog][RFU:v0.1.alpha] : https://cacoo.com/diagrams/mTm79GTjCk8HGxsz
  - sh/centralized-centrallog.rfu.sh => VM CENTRAL
  - sh/distributed-logstash.rfu.sh => VM's DISTRIBUTED

Depends
==========================
  - logstash [http://logstash.net] [v1.1.13]
  - redis [http://redis.io] [v2.6.13]
  - elasticsearch [http://elasticsearch.org] [v0.90.RC2]
  - kibana [http://kibana.org] [working]
  - mongoDB [http://www.mongodb.org/] [working]
  - graylog2 [http://graylog2.org] [working]

Objectifs : + vs - : Practice 
=============================
  - Benchmarks  (time faster)
  - Power       (volume)
  - Lean        (CPU,RAM)
  - Rest        (http+html+uri)
  
Kata Script REST
================
  - JavaScript ... : js/\<index\>/indexKata.js
  - Shell ........... : sh/\<index\>/indexKata.sh
  - Python ........ : py/\<index\>/indexKata.py
  - Ruby ........... : rb/\<index\>/indexKata.rb
  - JSON ........... : json, json_event, txt
  - StyleGuide
    - https://code.google.com/p/google-styleguide/
    - http://google-styleguide.googlecode.com/svn/trunk/javascriptguide.xml
    - http://google-styleguide.googlecode.com/svn/trunk/htmlcssguide.xml
    - http://google-styleguide.googlecode.com/svn/trunk/shell.xml
    - http://google-styleguide.googlecode.com/svn/trunk/pyguide.html
    - http://google-styleguide.googlecode.com/svn/trunk/xmlstyle.html
