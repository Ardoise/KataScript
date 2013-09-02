#!/bin/sh -e

PROGNAME=${0##*/}; echo $PROGNAME;
VERSION="0.0.0"; echo $VERSION;
DATE=$(date +'%Y-%m-%d'); echo $DATE;
AUTHOR=`id -un`;
[ -f "/etc/passwd" ] && AUTHOR=$(awk -v USER=$USER 'BEGIN { FS = ":" } $1 == USER { print $5 }' < /etc/passwd);
echo $AUTHOR;
[ -d "/tmp" ] || mkdir /tmp;
EMAIL_ADDRESS="<${REPLYTO:-${USER}@$HOSTNAME}>"; echo $EMAIL_ADDRESS

cat <<- _EOF_>licence.txt
	
	# This program is free software: you can redistribute it and/or modify
	# it under the terms of the GNU General Public License as published by
	# the Free Software Foundation, either version 3 of the License, or
	# (at your option) any later version.

	# This program is distributed in the hope that it will be useful,
	# but WITHOUT ANY WARRANTY; without even the implied warranty of
	# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	# GNU General Public License at (http://www.gnu.org/licenses/) for
	# more details.
_EOF_

JSON=json/cloud.json

# max=$(cat $JSON |jq -r -c '.profil | length'; # wc -l
for l in $(cat $JSON |jq -r -c '.profil[]'); do

  i=$(echo $l | jq -r '.id'); echo -n "$i|";
  s=$(echo $l | jq -r '.software'); echo -n "$s|";
  e=$(echo $l | jq -r '.platform'); echo -n "$e|";
  p=$(echo $l | jq -r '.path'); echo -n "$p|";
  c=$(echo $l | jq -r '.conf'); echo -n "$c|";
  g=$(echo $l | jq -r '.log'); echo -n "$g|";
  r=$(echo $l | jq -r '.run'); echo -n "$r|";
  
  n=$(cat $JSON | jq -r -c ".software.$s.name"); echo -n "$n|";
  N=$( echo $n | tr 'a-z' 'A-Z' ); echo -n "$N|";
  d=$(cat $JSON | jq -r -c ".software.$s.desc"); echo -n "$d|";
  v=$(cat $JSON | jq -r -c ".software.$s.version"); echo -n "$v|";
  b=$(cat $JSON | jq -r -c ".software.$s.binary"); echo -n "$b|";
  u=$(cat $JSON | jq -r -c ".software.$s.download"); echo -n "$u|";
  
  t=$(cat $JSON | jq -r -c .process.$i.daemon); echo -n "$t|";
  hi=$(cat $JSON | jq -r -c .process.$i.reload.input);  echo -n "$hi|";
  ho=$(cat $JSON | jq -r -c .process.$i.reload.output); echo -n "$ho|";
  
  #echo "$i|$e|$s|$v|$d|$b|$p|$t|$ho";
  echo
  [ -f "centrallog/centralized-generic.rfu.sh" ] && (\
  sed -e "s~xgenericx~$n~g" \
      -e "s~XGENERICX~$N~g" \
      -e "s~0.0.0~$v~g" \
      -e "s~#i#binary#i#~$b~g" \
      -e "s~#i#path#i#~$p~g" \
      -e "s~#i#download#i#~$u$b~g" \
      -e "s~#i#daemon#i#~$t~g" \
      -e "s~xlicensex~@License~g" \
      centrallog/centralized-generic.rfu.sh > /tmp/$e-$n.tmpl.sh;);
      #centrallog/centralized-generic.rfu.sh > centrallog/$e-$n.tmpl.sh;);
  
  [ -f "/tmp/$e-$n.tmpl.sh" ] && (\
  sed -i -e "/#i#start#i#/ s~.*~cat $JSON | jq -r .process.$i.start~e" \
         -e "/#i#status#i#/ s~.*~cat $JSON | jq -r .process.$i.status~e" \
         -e "/#i#stop#i#/ s~.*~cat $JSON | jq -r .process.$i.stop~e" \
         -e "/#i#pconfig#i#/ s~.*~cat $JSON | jq -r '\"PATTERN_FILE=\"+.process.$i.reload.pattern'~e" \
         -e "/#i#config#i#/ s~.*~cat $JSON | jq -r '\"CONF_FILE=\"+.process.$i.reload.conf'~e" \
         /tmp/$e-$n.tmpl.sh;);
         #centrallog/$e-$n.tmpl.sh;);

  #sed -i -e "/#i#update#i#/ s~.*~cat $JSON | jq -r '.dist_upgrade.install[]'~e" centrallog/centralized-$n.tmpl.sh;
done

rm -f *.sh~

exit 0

# Ard0ise
sudo apt-get update
sudo apt-get install curl git-core
clone_dir=/tmp/KataScript-build-$$;
git clone https://github.com/Ardoise/KataScript.git $clone_dir;
sudo sh $clone_dir/sh/centrallog/centralized-centrallog.tmpl.sh install;
sudo sh $clone_dir/sh/centrallog/centralized-centrallog.tmpl.sh dist-upgrade;
echo "rm -rf $clone_dir";
echo "unset clone_dir"; 
