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

  i=$(echo $l | jq -r '.id'); #echo $i
  s=$(echo $l | jq -r '.software'); #echo $s
  e=$(echo $l | jq -r '.platform'); #echo $e
  p=$(echo $l | jq -r '.path'); #echo $p
  c=$(echo $l | jq -r '.conf'); #echo $c
  g=$(echo $l | jq -r '.log'); #echo $g
  r=$(echo $l | jq -r '.run'); #echo $r
  
  n=$(cat $JSON | jq -r -c ".software.$s.name");
  N=$( echo $n | tr 'a-z' 'A-Z' );
  d=$(cat $JSON | jq -r -c ".software.$s.desc");
  v=$(cat $JSON | jq -r -c ".software.$s.version");
  b=$(cat $JSON | jq -r -c ".software.$s.binary");
  u=$(cat $JSON | jq -r -c ".software.$s.download");
  
  t=$(cat $JSON | jq -r -c .process.$i.daemon.initd);
  hi=$(cat $JSON | jq -r -c .process.$i.reload.input);  #host Input
  ho=$(cat $JSON | jq -r -c .process.$i.reload.output); #host Output
  
  echo "$e|$s|$v|$d|$b|$p|$t|$ho";
  
  [ -f "centrallog/$e-$n.tmpl.sh" ] && rm -f centrallog/$e-$n.tmpl.sh
  # 1 pass = many changes
  sed -e "s~xgenericx~$n~g" \
      -e "s~XGENERICX~$N~g" \
      -e "s~0.0.0~$v~g" \
      -e "s~#i#binary#i#~$b~g" \
      -e "s~#i#path#i#~$p~g" \
      -e "s~#i#download#i#~$u$b~g" \
      -e "s~#i#daemon#i#~$t~g" \
      -e "s~xlicensex~@License~g" \
      centrallog/centralized-generic.rfu.sh > centrallog/$e-$n.tmpl.sh;
  
  sed -i -e "/#i#start#i#/ s~.*~cat $JSON | jq -r .process.$i.start~e" \
         -e "/#i#status#i#/ s~.*~cat $JSON | jq -r .process.$i.status~e" \
         -e "/#i#stop#i#/ s~.*~cat $JSON | jq -r .process.$i.stop~e" \
         -e "/#i#pconfig#i#/ s~.*~cat $JSON | jq -r '\"PATTERN_FILE=\"+.process.$i.reload.pattern'~e" \
         -e "/#i#config#i#/ s~.*~cat $JSON | jq -r '\"CONF_FILE=\"+.process.$i.reload.conf'~e" \
         centrallog/$e-$n.tmpl.sh;

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
