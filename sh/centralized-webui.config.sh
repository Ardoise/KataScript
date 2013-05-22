#!/bin/sh

# DEPLOY CENTRALIZED SERVER : WEBUI
. ./stdlevel

cat <<EOF >centralized-logstash.getbin.sh
#!/bin/bash

[ -d "/var/lib/logstash" ] || sudo mkdir -p /var/lib/logstash ;
[ -d "/var/log/logstash" ] || sudo mkdir -p /var/log/logstash ;
[ -d "/etc/logstash" ] || sudo mkdir -p /etc/logstash ;
[ -d "/opt/logstash" ] || sudo mkdir -p /opt/logstash ;

cd /opt/logstash
[ -s "logstash-1.1.12-flatjar.jar" ] || sudo curl -OL https://logstash.objects.dreamhost.com/release/logstash-1.1.12-flatjar.jar
[ -s "logstash-1.1.11.dev-monolithic.jar" ] || sudo curl -OL http://logstash.objects.dreamhost.com/builds/logstash-1.1.11.dev-monolithic.jar
EOF
chmod a+x centralized-logstash.getbin.sh

cat <<EOF >centralized-webui.sh
#!/bin/sh

# nohup java -jar logstash-1.1.11.dev-monolithic.jar web --backend elasticsearch://127.0.0.1/ > wlogger-stdout.log 2>&1&

nohup /usr/bin/java -jar /opt/logstash/logstash-1.1.12-flatjar.jar web -vvv -f /etc/logstash/backend.conf --backend elasticsearch://192.168.17.89/ > wlogger-stdout.log 2>&1&
# Errno::ENOENT at /search
# No such file or directory - file:/.../logstash-1.1.12-flatjar.jar!/logstash/web/views/search/results.haml
# Ruby 	org/jruby/RubyFile.java: in initialize, line 333 

EOF
chmod a+x centralized-webui.sh;

cat <<EOF >centralized-webui.test.sh
echo -n $(date '+%d/%m/%Y %r')
curl -s -XGET http://127.0.0.1:9292/search
EOF
chmod a+x centralized-webui.test.sh

exit 0;
