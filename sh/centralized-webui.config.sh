#!/bin/sh

# DEPLOY CENTRALIZED SERVER : WEBUI
. ./stdlevel


cat <<EOF >centralized-logstash.getbin.sh
#!/bin/sh
[ -s "logstash-1.1.12-flatjar.jar" ] || curl -O http://logstash.objects.dreamhost.com/release/logstash-1.1.12-flatjar.jar
[ -s "logstash-1.1.11.dev-monolithic.jar" ] || curl -O http://logstash.objects.dreamhost.com/builds/logstash-1.1.11.dev-monolithic.jar
EOF
chmod a+x centralized-logstash.getbin.sh


cat <<EOF >centralized-webui.sh
#!/bin/sh

# nohup java -jar logstash-1.1.11.dev-monolithic.jar web --backend elasticsearch://127.0.0.1/ > wlogger-stdout.log 2>&1&

nohup java -jar logstash-1.1.12-flatjar.jar web --backend elasticsearch://127.0.0.1/ > wlogger-stdout.log 2>&1&
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
