#!/bin/bash

# MongoDB
# http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/
#
# created by : https://github.com/Ardoise

cat <<EOF >centralized-mongodb.getbin.sh
# apt-get install openjdk-6-jre
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
touch /etc/apt/sources.list.d/10gen.list
# echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list
sudo apt-get update
sudo apt-get install mongodb-10gen
EOF
chmod a+x centralized-mongodb.getbin.sh

cat <<EOF >centralized-mongodb.sh
echo "/etc/mongodb.conf"
echo "sudo service mongodb stop";
echo "sudo service mongodb start";
echo "sudo service mongodb restart";
/etc/init.d/mongodb status
/etc/init.d/mongodb force-reload
/etc/init.d/mongodb restart
EOF

cat <<EOF >centralized-mongodb.test.sh
cat <<ZEOF | mongo
db.test.save( { a: 1 } )
db.test.find()
exit
ZEOF
EOF

