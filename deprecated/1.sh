#!/bin/bash
# REF : http://logstash.net/docs/1.1.12/tutorials/getting-started-simple

cat <<EOF >logstash-simple.conf
input { stdin { type => "stdin-type"}}
output { stdout { debug => true debug_format => "json"}}
EOF

cat <<EOF >logstash-elasticsearch.conf
input { stdin { type => "stdin-type"}}
output { 
  stdout { debug => true debug_format => "json"}
  elasticsearch { embedded => true }
}
EOF

cat <<EOF >logstash-complex.conf
input {
  stdin {
    type => "stdin-type"
  }
  file {
    type => "syslog"
    # Wildcards work, here :)
    path => [ "/var/log/*.log", "/var/log/messages", "/var/log/syslog" ]
  }
}
output {
  stdout { }
  elasticsearch { embedded => true }
}
EOF

cat <<-EOF >logstash-indexer.conf
 input {
 redis {
 host => "refhost"
 data_type => "list"
 key => "logstash-redis"
 type => "redis-input"
 }
 }
 
filter {
 grok {
 type => "producer" # for logs of type "syslog"
 pattern => "%{SYSLOGLINE}"
 # You can specify multiple 'pattern' lines
 }
 multiline{
 type => "xyz-stdout-log"
 pattern => "^\s"
 what => previous
 }
 multiline{
 type => "xyz-server2-log"
 pattern => "^\s"
 what => previous
 }
 multiline{
 type => "xyz-server3-log"
 pattern => "^\s"
 what => previous
 }
 } 
output {
 
# enable stdout for debug purposes only
 stdout { }
 
#
 elasticsearch {
 host => "localhost"
 }
 }
EOF
 
cat <<-EOF >logstash-test.conf
 input{
 # XYZ Inputs
 file{
 type => "xyz-stdout-log"
 path => [ "/tmp/xyz-stdout.log" ]
 }
 file{
 type => "xyz-server2-log"
 path => [ "/tmp/xyz-server2.log" ]
 }
 file{
 type => "xyz-server3-log"
 path => [ "/tmp/xyz-server3.log" ]
 }
}
output{
 redis{
 host => 'loghost1'
 data_type => 'list'
 key => 'logstash-redis'
 }
# stdout{
 # }
 }
EOF
 
cat <<EOF >logstash-pattern.conf
# This is a comment. You should use comments to describe
# parts of your configuration.
input {
  ...
}
filter {
  ...
}
output {
  ...
}
# debug => false
# debug => true
# name => "Hello world"
# port => 33
# path => [ "/var/log/messages", "/var/log/*.log" ]
# path => "/data/mysql/mysql.log"
# match => [ "field1", "pattern1", "field2", "pattern2" ]
# The above would internally be represented as this hash: { "field1" => "pattern1", "field2" => "pattern2" }

EOF

cat <<EOF >logstash.cmd
{
 "@source":"stdin://jvstratusmbp.local/",
 "@type":"stdin",
 "@tags":[],
 "@fields":{},
 "@timestamp":"2013-05-14T07:20:16.092000Z",
 "@source_host":"jvstratusmbp.local",
 "@source_path":"/",
 "@message":"test"
}
EOF

echo "Type something in the console where you started logstash";
cat logstash.cmd;

# JRE ORACLE JROCKBIT TR  
JAVA_HOME=${FMW_HOME}/jrockit/current
LOGGER_HOME=$HOME/logger
 
nohup $JAVA_HOME/bin/java -jar $LOGGER_HOME/logstash.jar agent -f $LOGGER_HOME/shipper.conf > logger-stdout.log 2>&1&
# FIRST OUTPUT
nohup $JAVA_HOME/bin/java -jar $LOGGER_HOME/logstash-1.1.12-flatjar.jar agent -f $LOGGER_HOME/logstash-simple.conf > logstash-simple-stdout.log 2>&1&
echo "pid=$?"

# SECOND OUTPUT
nohup $JAVA_HOME/bin/java -jar $LOGGER_HOME/logstash-1.1.12-flatjar.jar agent -f $LOGGER_HOME/logstash-elasticsearch.conf  > logstash-elasticsearch-stdout.log 2>&1&
echo "pid=$?"

# TESTUI
nohup $JAVA_HOME/bin/java -jar $LOGGER_HOME/logstash-1.1.12-flatjar.jar agent -f $LOGGER_HOME/logstash-elasticsearch.conf -- web --backend elasticsearch://127.0.0.1/  > logstash-elasticsearch-wstdout.log 2>&1&
echo "pid=$?"

# COMPLEX OUTPUT
nohup $JAVA_HOME/bin/java -jar $LOGGER_HOME/logstash-1.1.12-flatjar.jar agent -f $LOGGER_HOME/logstash-complex.conf -- web --backend elasticsearch://127.0.0.1/  > logstash-complex-stdout.log 2>&1&
echo "pid=$?"

# TEST
curl -s http://127.0.0.1:9200/_status?pretty=true | grep logstash
curl -s -XGET http://127.0.0.1:9200/logstash-2013.05.14/_search?q=@type:stdin


# CONTROL PORTS
netstat -napt | grep -i LISTEN
echo "The 9200 and 9300 ports are the embedded ES listening."
echo "The 9301 and 9302 ports are the agent and web interfaces talking to ES. 9292 is the port the web ui listens on."
