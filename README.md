## KATASCRIPT REST/JSON Shell ReadyForUse

### PLATFORM Portable
##### INSTALL :
     $ vagrant box add saucy64 http://cloud-images.ubuntu.com/vagrant/saucy/current/saucy-server-cloudimg-amd64-vagrant-disk1.box
     $ vagrant init saucy64
     $ vagrant up
     $ vagrant ssh
     vagrant@vagrant-ubuntu-saucy-64:~$ sudo apt-get update
     vagrant@vagrant-ubuntu-saucy-64:~$ sudo apt-get install -y curl git-core sudo

### SERVICE RFU Centr@lL0g-1.1.0
  ![Screenshots](https://cacoo.com/diagrams/b8v677hxhjQriPld-BE94C.png)
  ![Screenshots](https://cacoo.com/diagrams/mTm79GTjCk8HGxsz-BE94C.png?t=1368912915182)

##### CONFIG :
[sh/json/cloud.json](https://github.com/Ardoise/KataScript/blob/master/sh/json/cloud.json)
    
##### INSTALL :
    $ clone_dir=/tmp/KataScript-build-$$;
    $ git clone https://github.com/Ardoise/KataScript.git $clone_dir;
    $ sudo bash $clone_dir/sh/centrallog/centralized-centrallog.tmpl.sh dist-upgrade;
    ...
    $ sudo bash $clone_dir/sh/centrallog/centralized-logstash.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/centralized-redis.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/centralized-elasticsearch.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/centralized-kibana3.tmpl.sh install;
    $ sudo bash $clone_dir/sh/centrallog/centralized-mongodb.tmpl.sh install;
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
      dist-upgrade  - upgrade distrib platform jruby::gems

C0mp0nents :
==========================
  - Logstash [http://logstash.net] [v1.4.0-1]
  - Redis [http://redis.io] [v2.8.7]
  - ElasticSearch [http://elasticsearch.org] [v1.1.1]
  - Kibana3 [http://kibana.org] [v3.m.5]
  - MongoDB [http://www.mongodb.org/] [v2.4.9]
  - Graylog2 [http://graylog2.org] [v0.0.0][working]
  - Flume [http://flume.apache.org] [v1.4.0][working]
  - JBossAS [http://download.jboss.org] [v7.1.1]
  - Vagrant [http://www.vagrantup.com/] [v1.4.2]

Objectifs : + vs - : Practice 
=============================
  - FAST        (time)
  - SCALE       (volume)
  - LEAN        (cpu,ram,io)
  - REST        (http+html+uri)
  
