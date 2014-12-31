## KATASCRIPT REST/JSON Shell ReadyForUse

### PLATFORM Portable
##### INSTALL :
     $ vagrant box add trusty64 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box
     $ vagrant init trusty64
     $ vagrant up
     $ vagrant ssh
     vagrant@vagrant-ubuntu-trusty-64:~$ sudo apt-get update
     vagrant@vagrant-ubuntu-trusty-64:~$ sudo apt-get install -y curl git-core sudo

### SERVICE RFU Centr@lL0g-1.4.12
  ![Screenshots](https://cacoo.com/diagrams/b8v677hxhjQriPld-BE94C.png?t=1398001932606)
  ![Screenshots](https://cacoo.com/diagrams/mTm79GTjCk8HGxsz-BE94C.png?t=1368912915182)

##### CONFIG :
[sh/json/cloud.json](https://github.com/Ardoise/KataScript/blob/master/sh/json/cloud.json)
    
##### INSTALL :
    $ clone_dir=/tmp/KataScript-build-$$;
    $ git clone https://github.com/Ardoise/KataScript.git $clone_dir;
    $ sudo bash $clone_dir/sh/centrallog/centralized-centrallog.tmpl.sh dist-upgrade;
    ...
    $ sudo bash $clone_dir/sh/centrallog/centralized-elasticsearch.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/centralized-kibana4.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/centralized-kibana3.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/centralized-nginx.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/centralized-logstash.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/centralized-redis.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/centralized-mongodb.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/centralized-hadoop.tmpl.sh install;
    ...
    $ sudo bash $clone_dir/sh/centrallog/distributed-logstash.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/distributed-flume.tmpl.sh install;
    ...
    $ echo "rm -rf $clone_dir";
    $ echo "unset clone_dir";
    
##### USAGE :
    $ sudo sh sh/centrallog/<context>-<component>.tmpl.sh <command>
     Commands :
      check         - check centrallog::<component>
      install       - install centrallog::<component>
      reload        - reload config centrallog::<component>
      remove        - remove centrallog::<component>
      start         - start centrallog::<component>
      status        - status centrallog::<component>
      stop          - stop centrallog::<component>
      upgrade       - upgrade centrallog::<component>
      dist-upgrade  - upgrade distrib platform jruby::gems python3::pip3

Softwares :
==========================
  - ElasticSearch [http://elasticsearch.org] [v1.4.2]
  - JBossAS [http://download.jboss.org] [v7.1.1]
  - Kibana3 [http://kibana.org] [v3.1.2]
  - Kibana4 [http://kibana.org] [v4.0.0-b3]
  - Logstash [http://logstash.net] [v1.4.2-1]
  - MongoDB [http://www.mongodb.org/] [v2.6.3]
  - Neo4J [http://www.neo4j.org] [v2.1.2]
  - Nginx [http://nginx.org] [v1.7.3]
  - Redis [http://redis.io] [v2.8.13]
  - Vagrant [http://www.vagrantup.com/] [v1.6.3]
  - ...
  - Flume [http://flume.apache.org] [v1.5.0][as soon]
  - Hadoop [http://hadoop.apache.org] [v2.4.1][as soon]
  - ...
  - Couchbase [http://www.couchbase.com/] [v3.0.1][as soon]
  - CouchDB [http://couchdb.apache.org/] [v1.6.1][as soon]
  - Kafka [http://couchdb.apache.org/] [v0.8.1-1][as soon]

Objectifs : + vs - : Practice 
=============================
  - FAST        (time)
  - SCALE       (volume)
  - LEAN        (cpu,ram,io)
  - REST        (http+html+uri)
  
