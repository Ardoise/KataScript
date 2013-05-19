#!/bin/bash

# DEPLOY DISTRIBUTED CLIENT : SHIPPER

cat <<EOF >distributed-logstash.getbin.sh
curl -O http://logstash.objects.dreamhost.com/release/logstash-1.1.12-flatjar.jar
EOF
chmod a+x distributed-logstash.getbin.sh

cat <<EOF >distributed-shipper.conf
input{
 # xyz Inputs
 file{
  type =&gt; "mon_type_1"
  path=&gt; ["/var/log/fichier1", "/var/log/fichier2"]
 }
 #on définit l'entrée de type fichier.
 file {
  type =&gt; "login" #on attribue le type login aux lignes lues dans ce fichier.
  path =&gt; [ "/var/tmp/test"]
 }
 file {
  type => "apache-log"
  path => "/var/log/apache2/access.log"
 }
}
filter {
  grok {
    type =&gt; "mon_type_1"
    pattern =&gt; "%{WORD} %{WORD}"
    # pattern =&gt; "%{WORD :premier_mot} %{WORD:second_mot}"
  }
  mutate {
    type =&gt; "mon_type_1"
    replace =&gt; ["@message","%{second_mot} %{premier_mot}"]
  }
  #On commence par sélectionner les lignes contenant "Login :"
  grep {
    match =&gt; ["@message","^Login : .*"] #ici on ne prend que les lignes commençant par Login :
    type =&gt; "login" #le filtre s'applique aux lignes du type login.
  }
  #On sélectione les infos que l'on veut sur la ligne
  grok {
    pattern =&gt;"Login : %{WORD:login}" #ici on sélectionne le mot qui suit les deux points et le stocke dans le tableau associatif fields avec pour clé "login".
    type =&gt; "login" #le filtre s'applique aux lignes du type login.
  }
  #On reforme le message avec les infos sélectionnées
  mutate {
    type =&gt; "login"
    replace =&gt; ["@message","%{login}"] #On remplace le contenu du champ message en ne mettant que la valeur du login.
  }
  grok {
    type => "apache-log"
    pattern => "%{COMBINEDAPACHELOG}"
  }
}
output {
  #On garde la sortie standard pour le debug, on l'enlèvera lorsque le résultat nous conviendra
  stdout {
    debug =&gt; true
    debug_format => "json"
  }
  file {
   path =&gt; "/var/log/mon_fichier"
   type =&gt; "mon_type_1"
  }
  redis{
    host => 'centralized'
    data_type => 'list'
    key => 'logstash-redis'
  }
  file {
    type =&gt; "login"
    path =&gt; "/var/tmp/sortie"
    flush_interval =&gt; 0 #on écrira dans le fichier après chaque message
    message_format =&gt; "%{@message}" #on veut simplement écrire le contenu du champ "message"
  }
  # greylog
  gelf {
    type => "apache-log"
    host => "localhost"
    facility => "apache"
    level => "INFO"
    sender => "%{@source_host}"
  }
}
EOF

cat <<EOF >distributed-shipper.sh
nohup java -jar logstash-1.1.12-flatjar.jar agent -f distributted-shipper.conf > logger-stdout.log 2>&1&
EOF
chmod a+x distributed-shipper.sh

cat <<EOF >distributed-shipper.test.sh
echo test &gt; /var/tmp/test
echo test &gt; /var/tmp/test
echo test &gt; /var/tmp/test
echo "Login : test" &gt; /var/tmp/test
echo "Login : test" &gt; /var/tmp/test
echo "Login : test" &gt; /var/tmp/test
EOF
chmod a+x distributed-shipper.sh

exit 0;
