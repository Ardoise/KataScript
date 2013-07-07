#!/bin/sh -e
### BEGIN INIT INFO
# Provides: centrallog: mongodb
# Short-Description: DEPLOY SERVER: [STORAGESEARCH]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130707
### END INIT INFO

# Description: SERVICE CENTRALLOG: mongodb (NoSQL, INDEX, SEARCH)
# - deploy mongodb v2.4.5
#
# Requires : you need root privileges tu run this script
# Requires : JRE7 to run mongodb
# Requires : curl
#
# CONFIG:   [ "/etc/mongodb", "/etc/mongodb/test" ]
# BINARIES: [ "/opt/mongodb/", "/usr/share/mongodb/" ]
# LOG:      [ "/var/log/mongodb/" ]
# RUN:      [ "/var/mongodb/mongodb.pid" ]
# INIT:     [ "/etc/init.d/mongodb" ]

SCRIPT_OK=0
SCRIPT_ERROR=1

DESCRIPTION="MongoDB Server";
SCRIPT_NAME=`basename $0`
NAME=mongodb
DEFAULT=/etc/default/$NAME

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

cat <<-'EOF' >centralized-mongodb.getbin.sh
#!/bin/sh

[ -d "/opt/mongodb" ] || sudo mkdir -p /opt/mongodb;
[ -d "/etc/mongodb/test" ] || sudo mkdir -p /etc/mongodb/test;
[ -d "/var/lib/mongodb" ] || sudo mkdir -p /var/lib/mongodb;
[ -d "/var/log/mongodb" ] || sudo mkdir -p /var/log/mongodb;

SITE=http://downloads-distro.mongodb.org/

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

case $DISTRIB in
Ubuntu*|Debian*)
  echo "apt-get update";
  echo "apt-get install openjdk-7-jre";
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
  touch /etc/apt/sources.list.d/10gen.list
  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list
  sudo apt-get update
  echo 'echo "mongodb-10gen hold" | dpkg --set-selections'
  echo "sudo apt-get install mongodb-10gen=2.2.5"
  sudo apt-get install mongodb-10gen
;;
Red*Hat*)
  touch /etc/yum.repos.d/10gen.repo
  cat <<-ZEOF
[10gen]
name=10gen Repository
#32bits
#baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/i686
#64bits
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64
gpgcheck=0
enabled=1
ZEOF
  echo "yum install mongo-10gen-2.2.5 mongo-10gen-server-2.2.5"
  echo 'echo "#to pin a package" >> /etc/yum.conf'
  echo 'echo "#exclude=mongo-10gen,mongo-10gen-server" >> /etc/yum.conf'
  yum install mongo-10gen mongo-10gen-server
;;
*)
 : 
;;
esac

EOF
chmod a+x centralized-mongodb.getbin.sh


cat <<EOF >centralized-mongodb.putconf.sh
#!/bin/sh -e

cat <<CEOF >mongodb.conf
# mongodb.conf

# Where to store the data.

# Note: if you run mongodb as a non-root user (recommended) you may
# need to create and set permissions for this directory manually,
# e.g., if the parent directory isn't mutable by the mongodb user.
dbpath=/var/lib/mongodb
logpath=/var/log/mongodb/mongodb.log
logappend=true
port = 27017

# Disables write-ahead journaling
# nojournal = true

# Enables periodic logging of CPU utilization and I/O wait
#cpu = true

# Turn on/off security.  Off is currently the default
#noauth = true
#auth = true

# Verbose logging output.
#verbose = true

# Inspect all client data for validity on receipt (useful for
# developing drivers)
#objcheck = true

# Enable db quota management
#quota = true

# Set oplogging level where n is
#   0=off (default)
#   1=W
#   2=R
#   3=both
#   7=W+some reads
#diaglog = 0

# Ignore query hints
#nohints = true

# Disable the HTTP interface (Defaults to localhost:28017).
#nohttpinterface = true

# Turns off server-side scripting.  This will result in greatly limited
# functionality
#noscripting = true

# Turns off table scans.  Any query that would do a table scan fails.
#notablescan = true

# Disable data file preallocation.
#noprealloc = true

# Specify .ns file size for new databases.
# nssize = <size>

# Accout token for Mongo monitoring server.
#mms-token = <token>

# Server name for Mongo monitoring server.
#mms-name = <server-name>

# Ping interval for Mongo monitoring server.
#mms-interval = <seconds>

# Replication Options

# in master/slave replicated mongo databases, specify here whether
# this is a slave or master
#slave = true
#source = master.example.com
# Slave only: specify a single database to replicate
#only = master.example.com
# or
#master = true
#source = slave.example.com

# in replica set configuration, specify the name of the replica set
# replSet = setname 

CEOF
chmod 644 mongodb.conf
[ -d "/etc/mongodb/test" ] || sudo mkdir -p /etc/mongodb/test;
[ -d "/etc/mongodb/test" ] && mv mongodb.conf /etc/mongodb/test/;

EOF



cat <<EOF >centralized-mongodb.sh
echo "view /etc/mongodb/test/mongodb.conf"
#/etc/init.d/mongodb status
#/etc/init.d/mongodb force-reload
#/etc/init.d/mongodb restart
sudo service mongodb status;
sudo service mongodb reload;
sudo service mongodb stop;
sudo service mongodb start;
sudo service mongodb restart;
EOF


cat <<'EOF' >centralized-mongodb.test.sh
#!/bin/sh

cat <<'MEOF' | mongo
db
show dbs
db.test.save( { a: 1 } )
db.test.find()
it
exit
MEOF

cat <<'MEOF' | mongo
db
use mydb
db
show dbs
var p = {firstname: "Dev", lastname: "Ops"}
db.mydb.save(p)
db.mydb.find()
exit
MEOF

cat <<'MEOF' | mongo
//SHOW DATABASES
show dbs

//CREATE DATABASE [IF NOT EXISTS] mydb
//USE mydb
use mydb

//CREATE TABLE things (name VARCHAR(30), x VARCHAR(30));
//DESCRIBE things

//SHOW TABLES;
show collections

//INSERT INTO things VALUES ('mongo',NULL);
//INSERT INTO things VALUES (NULL,'3');
j = { name : "mongo" }
k = { x : 3 }
db.things.insert( j )
db.things.insert( k )

//SELECT * FROM things WHERE 1
db.things.find()

//ALTER TABLE things (name VARCHAR(30), x INTEGER, j INTEGER);
//INSERT INTO things VALUES (null,'4','1');
//INSERT INTO things VALUES (null,'4','2');
//INSERT INTO things VALUES (null,'4','3');
//...
//INSERT INTO things VALUES (null,'4','10');
for (var i = 1; i <= 10; i++) db.things.insert( { x : 4 , j : i } )

//SELECT * FROM things WHERE 1
db.things.find()
var c = db.things.find()
while ( c.hasNext() ) printjson( c.next() )
//ALTERNATIVE
db.things.find().forEach(printjson);

//SELECT * FROM things WHERE 1 ORDER BY LIMIT 1 OFFSET 3
var c = db.things.find()
printjson( c [ 4 ] )

//SELECT * FROM things WHERE name='mongo'
db.things.find( { name : "mongo" } )

//SELECT * FROM things WHERE X='4'
db.things.find( { x : 4 } )

//SELECT * FROM things WHERE x='4' and j='1'
db.things.find( { x : 4 } , { j : 1 } )

//SELECT * FROM things WHERE LIMIT 0,3
db.things.find().limit(3)

//SELECT * FROM things WHERE x>'4'
db.things.find({ x: { '$gt': 4 } })
//  { '$gt': 4 } Plus grand que
//  { '$gte': 4 } Plus grand ou égal à
//  { '$lt': 4 } Plus petit que
//  { '$lte': 4 } Plus petit ou égal à
//  { '$ne': 4 } Différent de
//  { '$all': [3, 4, 5] } Comporte toutes les valeurs
//  { '$in': [3, 4] } Comporte au moins une des valeurs
//  { '$exists': true } Le champ doit exister (ou ne pas exister si false)

//SELECT * FROM things WHERE name LIKE %mo%.
db.things.find({ name: /^mo/ });

//SELECT * FROM things WHERE 1 ORDER BY x
db.things.find({ x: { '$gt': 3 } }).sort({ x: -1 });

//UPDATE things ...
db.things.update({ name: "mongo" }, { $set: { name: "mongoDB" } }, false, true);

//DELETE * FROM things WHERE x>5
db.things.remove({ x: { '$gt': 5 } });

exit
MEOF


yourIP=$(hostname -I | cut -d' ' -f1);
yourIP=${yourIP:-localhost};

# XPUT
curl -XPUT 'http://'${yourIP}':9200/person-'$(date +"%Y.%m.%d")'/mongodb/_meta' -d '{
    "type": "mongodb", 
    "mongodb": { 
        "db": "mydb",
        "collection": "person"
    }, 
    "index": { 
        "name": "iperson",
        "type": "cperson"
    }
}' && echo


# GET
curl -XGET 'http://'${yourIP}':9200/mydb/_search?q=firstname:Dev' && echo
curl -XGET 'http://'${yourIP}':9200/cperson/_search?q=firstname:Dev' && echo
curl -XGET 'http://'${yourIP}':9200/iperson/_search?q=firstname:Dev' && echo
curl -XGET 'http://'${yourIP}':9200/mydb/51bc5eb79da229a2f7980b5b?pretty=true' && echo

# XPUT
curl -XPUT 'http://'${yourIP}':9200/person-'$(date +"%Y.%m.%d")'/mongodb/_meta' -d '{
     "type": "mongodb",
    "mongodb": { 
        "db": "mydb", 
        "collection": "fs", 
        "gridfs": true 
    }, 
    "index": {
        "name": "ifile", 
        "type": "file"
    }
}' && echo

# PUT RIVER FILES
# echo '${MONGO_HOME}/bin/mongofiles --host '${yourIP}':27017 --db mydb --collection fs put test-document-2.pdf'
# GET INDEX
# echo 'curl -XGET http://'${yourIP}':9200/files/4f230588a7da6e94984d88a1?pretty=true'

EOF
chmod +x centralized-mongodb.test.sh


echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-mongodb : get binaries ..."
sh centralized-mongodb.getbin.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-mongodb : get binaries [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-mongodb : put config ..."
sh centralized-mongodb.putconf.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-mongodb : put config [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-mongodb : start ..."
sh centralized-mongodb.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-mongodb : start [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-mongodb : test ..."
sh centralized-mongodb.test.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-mongodb : test [ OK ]"

exit 0
