#!/bin/bash

set -e

[ -d "/opt/kibana" ] || sudo mkdir -p /opt/kibana;
[ -d "/etc/kibana/tmp" ] || sudo mkdir -p /etc/kibana/tmp;
[ -d "/var/log/kibana" ] || sudo mkdir -p /var/log/kibana;
[ -d "/var/lib/kibana" ] || sudo mkdir -p /var/lib/kibana;


cat <<EOF >centralized-kibana.getbin.sh
#!/bin/bash
[ -d "/opt/kibana" ]  && (
  cd /opt/kibana
  git clone --branch=kibana-ruby https://github.com/rashidkpc/Kibana.git
  mv Kibana kibana
  cd kibana
  sudo bundle install
  sudo ruby kibana.rb
  
  # require : RubyGems
  # http://production.cf.rubygems.org/rubygems/rubygems-2.0.3.zip
  sudo gem update --system
  sudo gem install rubygems-update
  sudo update_rubygems
)
EOF
chmod a+x centralized-kibana.getbin.sh

cat <<EOF >centralized-kibana.putconf.sh
#!/bin/bash
# gem update --system
EOF

cat <<EOF >centralized-kibana.sh
#!/bin/bash
sudo service kibana start
EOF
chmod a+x centralized-kibana.sh

cat <<EOF >centralized-kibana.test.sh
#!/bin/bash
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: "
EOF
chmod a+x centralized-kibana.test.sh



# REST : CHILD
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : get binaries ..."
sh centralized-kibana.getbin.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : get binaries [ OK ]"
# echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : put config ..."
# sh centralized-kibana.putconf.sh;
# echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : put config [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : start service ..."
sh centralized-kibana.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : start service [ OK ]"
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : test service ..."
sh centralized-kibana.test.sh;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: centralized-kibana : test service [ OK ]"

exit 0
