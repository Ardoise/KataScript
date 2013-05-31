KATASCRIPT SERVICE ReadyForUse
==============================
  - sh/centralized-centrallog.rfu.sh 
    - in: (syslog, Apache2, stdin)
    - out: (NoSQL, WebUI, Search, Index, Storage, centralized)
  - sh/distributed-logstash (working)
    - in: (syslog, Apache2, stdin)
    - out: (centralized)

Kata Script REST
================
  - JavaScript ... : js/\<index\>/indexKata.js
  - Shell ........... : sh/\<index\>/indexKata.sh
  - Python ........ : py/\<index\>/indexKata.py
  - Ruby ........... : rb/\<index\>/indexKata.rb

Tested with data structure
==========================
  - json, json_event, txt

Depends
==========================
  - logstash [http://logstash.net]
  - redis [http://redis.io]
  - elasticsearch [http://elasticsearch.org]
  - kibana [http://kibana.org]
  - graylog2 [http://graylog2.org]

Objectifs : + vs - : Practice 
=============================
  - Benchmarks  (time faster)
  - Power       (volume)
  - Lean        (CPU,RAM)
  - Rest        (http+html+uri)
  - StyleGuide
    - https://code.google.com/p/google-styleguide/
    - http://google-styleguide.googlecode.com/svn/trunk/javascriptguide.xml
    - http://google-styleguide.googlecode.com/svn/trunk/htmlcssguide.xml
    - http://google-styleguide.googlecode.com/svn/trunk/shell.xml
    - http://google-styleguide.googlecode.com/svn/trunk/pyguide.html
    - http://google-styleguide.googlecode.com/svn/trunk/xmlstyle.html
