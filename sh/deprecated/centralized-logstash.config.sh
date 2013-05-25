#!/bin/sh

# DEPLOY CENTRALIZED SERVER : BROKER, INDEXER, SHIPPER, STORAGESEARCH, WEBUI
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

cat <<EOF >centralized-logstash-elasticsearch.conf
input {
   file {
      type => "linux-syslog"
      #path => [ "/var/log/messages" ]
      path => [ "/var/log/syslog" ]
   }
   file {
      type => "apache-access"
      #path => [ "/var/log/httpd/access_log", "/var/log/apache2/access.log" ]
      path => [ "/var/log/apache2/access.log" ]
   }
   file {
      type => "apache-error"
      #path => [ "/var/log/httpd/error_log", "/var/log/apache2/error.log"]
      path => [ "/var/log/apache2/error.log" ]
   }
}
output {
   stdout {
   }
   elasticsearch {
      embedded => false
      host => "192.168.17.89"
      cluster => "centrallog"
   }
}
EOF
[ -d "/opt/centrallog" ] || sudo mkdir -p /opt/centrallog ;
[ -d "/opt/centrallog" ] && (
  sudo cp centralized-logstash-elasticsearch.conf /opt/centrallog/;
)


exit 0;
