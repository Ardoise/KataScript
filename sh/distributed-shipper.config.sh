#!/bin/bash

# DEPLOY DISTRIBUTED CLIENT : SHIPPER
. ./stdlevel

cat <<EOF >distributed-logstash.getbin.sh
#!/bin/sh
[ -s "logstash-1.1.12-flatjar.jar" ] || curl -O http://logstash.objects.dreamhost.com/release/logstash-1.1.12-flatjar.jar
[ -s "logstash-1.1.11.dev-monolithic.jar" ] || curl -O http://logstash.objects.dreamhost.com/builds/logstash-1.1.11.dev-monolithic.jar
EOF
chmod a+x distributed-logstash.getbin.sh

cat <<EOF >distributed-shipper.conf
input{
  #mode debug
  #stdin {
  #  type => "stdin-type"
  #}
  #xyz Inputs
  #file{
  #  type => "mon_type_1"
  #  path => ["/var/log/fichier1", "/var/log/fichier2"]
  #}
  #login
  #file {
  #  type => "login" #on attribue le type login aux lignes lues dans ce fichier.
  #  path => ["/var/tmp/test"]
  #}
  #logstash
  #file { 
  #  path => ["/var/log/apache2/access_json.log", "/var/log/httpd/access_json.log"]
  #  type => apache
    #This format tells logstash to expect 'logstash' json events from the file.
  #  format => json_event 
  #}
  #syslog
  #file {
  #  type => "linux-syslog"
  #  path => ["/var/log/messages"]
  #}
  #http access
  file {
    type => "apache-access"
    path => ["/var/log/apache2/access.log", "/var/log/httpd/access.log"]
  }
  #http error
  #file {
  #  type => "apache-error"
  #  path => ["/var/log/apache2/error.log", "/var/log/httpd/error.log"]
  #}
  #http combined
  #file {
  #  type => "apache-combined"
  #  path => ["/var/log/apache2/error_log"]
  #}
}
filter {
  #grok {
  #  type => "mon_type_1"
  #  pattern => "%{WORD} %{WORD}"
    # pattern => "%{WORD :premier_mot} %{WORD:second_mot}"
  #}
  #mutate {
  #  type => "mon_type_1"
  #  replace => ["@message","%{second_mot} %{premier_mot}"]
  #}
  #On commence par sélectionner les lignes contenant "Login :"
  #grep {
  #  match => ["@message","^Login : .*"] #ici on ne prend que les lignes commençant par Login :
  #  type => "login" #le filtre s'applique aux lignes du type login.
  #}
  #On sélectione les infos que l'on veut sur la ligne
  #grok {
  #  pattern => "Login : %{WORD:login}" #ici on sélectionne le mot qui suit les deux points et le stocke dans le tableau associatif fields avec pour clé "login".
  #  type => "login" #le filtre s'applique aux lignes du type login.
  #}
  #On reforme le message avec les infos sélectionnées
  #mutate {
  #  type => "login"
  #  replace => ["@message","%{login}"] #On remplace le contenu du champ message en ne mettant que la valeur du login.
  #}
  #grok {
  #  type => "apache-combined"
  #  pattern => "%{COMBINEDAPACHELOG}"
  #}
}
output {
  #On garde la sortie standard pour le debug, on l'enlèvera lorsque le résultat nous conviendra
  #stdout {
  #  debug => true
  #  debug_format => "json"
  #}
  #file {
  #  path => "/var/log/mon_fichier"
  #  type => "mon_type_1"
  #}
  #file {
  #  type => "login"
  #  path => "/var/tmp/sortie"
  #  flush_interval => 0 #on écrira dans le fichier après chaque message
  #  message_format => "%{@message}" #on veut simplement écrire le contenu du champ "message"
  #}
  #STANDALONE
  elasticsearch {
    embedded => false
    host => "127.0.0.1"
    cluster => "centrallog"
  }
#AMQP
#redis { 
#host => "127.0.0.1" 
#data_type => "list" 
#key => "logstash-redis"
#}
}
EOF

cat <<EOF >distributed-shipper.sh
# -Des.path.data="/var/lib/elasticsearch/" 
# -jar logstash-1.1.9-monolithic.jar agent -vvv 
# -f "etc/distributed-elasticsearch.conf"
# -f "dlogger-stdout.log"  
nohup java -jar logstash-1.1.12-flatjar.jar agent -vvv -f ./distributed-shipper.conf > dlogger-stdout.log 2>&1&
EOF
chmod a+x distributed-shipper.sh

cat <<EOF >distributed-shipper.test.sh
echo test > /var/tmp/test
echo "Login : test" > /var/tmp/test
EOF
chmod a+x distributed-shipper.sh

exit 0;
