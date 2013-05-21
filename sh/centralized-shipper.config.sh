#!/bin/bash

# DEPLOY CENTRALIZED SERVER : SHIPPER
. ./stdlevel

cat <<"EOF" >centralized-vhost.conf
Listen 81
<VirtualHost *:81>
  ServerAdmin webmaster@localhost

  DocumentRoot /var/www
  <Directory />
    Options FollowSymLinks
    AllowOverride None
  </Directory>
  <Directory /var/www/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride None
    Order allow,deny
    allow from all
  </Directory>

  ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
  <Directory "/usr/lib/cgi-bin">
    AllowOverride None
    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
    Order allow,deny
    Allow from all
  </Directory>

  ErrorLog ${APACHE_LOG_DIR}/error.log

  # Possible values include: debug, info, notice, warn, error, crit,
  # alert, emerg.
  LogLevel warn

  # LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
  # LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
  # LogFormat "%h %l %u %t \"%r\" %>s %O" common
  # LogFormat "%{Referer}i -> %U" referer
  # LogFormat "%{User-agent}i" agent
  LogFormat "{ \"@timestamp\": \"%{%Y-%m-%dT%H:%M:%S%z}t\", \"@fields\": { \"client\": \"%a\", \"duration_usec\": %D, \"status\": %s, \"request\": \"%U%q\", \"method\": \"%m\", \"referrer\": \"%{Referer}i\" } }" logstash_json
  
  CustomLog ${APACHE_LOG_DIR}/access.log combined
  # Write our 'logstash_json' logs to logs/access_json.log
  # CustomLog logs/access_json.log logstash_json
  CustomLog ${APACHE_LOG_DIR}/access_json.log logstash_json

  Alias /doc/ "/usr/share/doc/"
  <Directory "/usr/share/doc/">
    Options Indexes MultiViews FollowSymLinks
    AllowOverride None
    Order deny,allow
    Deny from all
    Allow from 127.0.0.0/255.0.0.0 ::1/128
  </Directory>

</VirtualHost>
EOF
[ -d "/etc/logstash" ] || mkdir -p ./etc/logstash;
[ -d "/etc/logstash" ] && cp centralized-vhost.conf ./etc/logstash/
[ -d "/etc/apache2/sites-enabled/" ] && (
  sudo cp centralized-vhost.conf /etc/apache2/sites-enabled/;
  sudo apache2ctl configtest;
)

cat <<"EOF" >centralized-macro.conf
# Create a Macro named logstash_log that is used in the VirtualHost
# It defines, on the fly, a macro for the specific vhost $servername
# and anchors its @source, $source_host and @source_path.
# 
<Macro logstash_log ${servername} ${hostname}>
 LogFormat "{ \
   \"@source\":\"file ://${hostname}//var/log/apache2/${servername}-access_log\",\"@source_host\": \"${hostname}\", \
   \"@source_path\": \"/var/log/apache2/${servername}-access_log\", \
   \"@tags\":[\"${servername}\"], \
   \"@message\": \"%h %l %u %t \\\"%r\\\" %>s %b\", \ 
   \"@fields\": { \
	   \"timestamp\": \ "%{%Y-%m-%dT%H:%M:%S%z}t\", \
	   \"clientip\": \" %a\", \
	   \"duration\": %D , \
	   \"status\": %>s, \
	   \"request\": \"% U%q\", \
	   \"urlpath\": \"% U\", \
	   \"urlquery\": \" %q\", \
	   \"method\": \"%m \", \
	   \"bytes\": %B, \ 
	   \"vhost\": \"%v\ " \
   } \
 }" logstash_apache_json

 CustomLog /var/log/apache2/${servername}-access_log json_event_log
</Macro>
EOF
[ -d "/etc/logstash" ] || mkdir -p ./etc/logstash;
[ -d "/etc/logstash" ] && cp centralized-macro.conf ./etc/logstash/
[ -d "/usr/lib/apache2/modules/mod_macro.so" ] && (
  sudo cp centralized-macro.conf /etc/apache2/conf.d/;
  sudo apachectl configtest;
)

cat <<EOF >centralized-shipper.conf
input {
  stdin {
    type => "stdin-type"
  }
  file { 
    path => ["/var/log/apache2/access_json.log", "/var/log/httpd/access_json.log"]
    type => apache
    # This format tells logstash to expect 'logstash' json events from the file.
    format => json_event 
  }
}
filter {
  # GreyLog2
  grok {
    type => "apache-log"
    pattern => "%{COMBINEDAPACHELOG}"
  }
}
output {
  stdout { 
    debug => true 
    debug_format => "json"
  }
  # send flowing : test local
  redis { 
    host => "127.0.0.1" 
    data_type => "list" 
    key => "logstash-redis"
  }
  # GreyLog2
  gelf {
    type => "apache-log"
    host => "127.0.0.1"
    facility => "apache"
    level => "INFO"
    sender => "%{@source_host}"
  }
 }
EOF
[ -d "/etc/logstash" ] || mkdir -p ./etc/logstash;
[ -d "/etc/logstash" ] && cp centralized-shipper.conf ./etc/logstash/


cat <<EOF >centralized-shipper.sh
#!/bin/sh
#nohup sudo java -jar logstash-1.1.12-monolithic.jar agent -f ./centralized-shipper.conf > logger-stdout.log 2>&1&
nohup java -jar logstash-1.1.12-flatjar.jar agent -f ./centralized-shipper.conf > logger-stdout.log 2>&1&
EOF
chmod a+x centralized-shipper.sh

cat <<EOF >centralized-shipper.test.sh
#!/bin/sh
ps -efa | grep logstash | grep -v "grep"
EOF
chmod a+x centralized-shipper.test.sh

exit 0;
