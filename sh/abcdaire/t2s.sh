#!/bin/bash
t2s() { wget -q -U Mozilla -O $(tr ' ' _ <<< "$1"| cut -b 1-15).mp3 "http://translate.google.com/translate_tts?ie=UTF-8&tl=en&q=$(tr ' ' + <<< "$1")"; }

t2s 'Who are you?'

# command repeat per 1s
watch --interval 1 ls -lah

#
ls | grep uniq -c | sed -r 's/([0-9]+)\s(.*)/"\2": \1,/;$s/,/\n}/;1i{'

# Where I am in google map
curl -s http://geoiplookup.wikimedia.org/ | python3 -c 'import sys, json, string, webbrowser; webbrowser.open(string.Template("http://maps.google.com/maps?q=$lat,$lon").substitute(json.loads(sys.stdin.read().split("=")[-1])))'

# JSON parse with Python
curl -s "http://feeds.delicious.com/v2/json?count=5" | python -m json.tool | less -R
echo '{"json":"obj"}' | python -m simplejson.tool


# Start server from path
ruby -rwebrick -e'WEBrick::HTTPServer.new(:Port => 3000, :DocumentRoot => Dir.pwd).start'

# stderr red
color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1

# delete key matching with pattern in Redis
for key in `echo 'KEYS pattern*' | redis-cli | awk '{print $1}'`; do echo DEL $key; done | redis-cli
# Redis ping
TIME=$( { time redis-cli PING; } 2>&1 ) ; echo $TIME | awk '{print $3}' | sed 's/0m//; s/\.//; s/s//; s/^0.[^[1-9]*//g;'



| sed 's/": {/{/g; s/^[ \t]*"//g; s/" :/ :/g'