## KATASCRIPT REST ReadyForUse
### service Centr@lL0g :
  ![Screenshots](https://cacoo.com/diagrams/mTm79GTjCk8HGxsz-BE94C.png?t=1368912915182)

    [INSTALL]
    clone_dir=/tmp/KataScript-build-$$;
    git clone https://github.com/Ardoise/KataScript.git $clone_dir;
    sudo sh $clone_dir/sh/centrallog/centralized-centrallog.tmpl.sh dist-upgrade;
    sudo sh $clone_dir/sh/centrallog/centralized-centrallog.tmpl.sh install;
    ...
    sudo sh $clone_dir/sh/centrallog/centralized-logstash.tmpl.sh install;
    sudo sh $clone_dir/sh/centrallog/centralized-redis.tmpl.sh install;
    sudo sh $clone_dir/sh/centrallog/centralized-elasticsearch.tmpl.sh install;
    sudo sh $clone_dir/sh/centrallog/centralized-kibana3.tmpl.sh install;
    sudo sh $clone_dir/sh/centrallog/centralized-mongodb.tmpl.sh install;
    sudo sh $clone_dir/sh/centrallog/centralized-flume.tmpl.sh install;
    sudo sh $clone_dir/sh/centrallog/distributed-logstash.tmpl.sh install;
    ...
    echo "rm -rf $clone_dir";
    echo "unset clone_dir";
    
    [RFU:v0.1.1-alpha3]
    sh/json/cloud.json                            # VM[]::SOFTWARE[]       STATEMENT
    sh/centrallog/<context>-<component>.tmpl.sh   # SOFTWARE[]::COMMAND[]  LIFECYCLE
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
    
    [RFU:v0.1.0]
    sh/centrallog/centralized-centrallog.rfu.sh   # VM CENTRAL
    sh/centrallog/distributed-logstash.rfu.sh     # VM's DISTRIBUTED
    sh/centrallog/distributed-flume.rfu.sh        # VM's DISTRIBUTED
  
### service st@nd@l0ne :
    
    [RFU:v0.1.0]
    sh/standalone/standalone-jboss.rfu.sh     # VM CENTRAL
    sh/standalone/standalone-ruby.rfu.sh      # VM CENTRAL

C0mp0nents :
==========================
  [cloud.json](https://github.com/Ardoise/KataScript/blob/master/sh/json/cloud.json)
  - logstash [http://logstash.net] [v1.1.13]
  - redis [http://redis.io] [v2.6.16]
  - elasticsearch [http://elasticsearch.org] [v0.90.3]
  - kibana3 [http://kibana.org] [v3m2]
  - mongoDB [http://www.mongodb.org/] [v2.4.6]
  - graylog2 [http://graylog2.org] [v0.0.0][working]
  - flume [http://flume.apache.org] [v1.4.0][working]
  - JBossAS [http://download.jboss.org] [v7.1.1]
  - vagrant [http://www.vagrant.org/] [v1.3.1]

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
