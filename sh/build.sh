#!/bin/sh -e

PROGNAME=${0##*/}; echo $PROGNAME;
VERSION="0.0.0"; echo $VERSION;
DATE=$(date +'%Y-%m-%d'); echo $DATE;
AUTHOR=$(awk -v USER=$USER 'BEGIN { FS = ":" } $1 == USER { print $5 }' < /etc/passwd); echo $AUTHOR
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

JSON=json/centrallog.json

for l in $(cat $JSON |jq -r '.hosts[0].centralized[]'); do
  c=$(echo $l | cut -d':' -f1); C=$( echo $c | tr 'a-z' 'A-Z' );
  d=$(cat $JSON | jq -r ".components.$c.desc");
  n=$(cat $JSON | jq -r ".components.$c.name");
  v=$(cat $JSON | jq -r ".components.$c.version");
  
  echo "hostc|$v|$n|$d";
  
  sed -e "s/xgenericx/$n/g" \
      -e "s/XGENERICX/$C/g" \
      -e "s/0.0.0/$v/g" \
      -e "s/xlicensex/@License/g" \
      centrallog/centralized-generic.rfu.sh > centrallog/centralized-$c.tmpl.sh;
      
  sed -i -e "/#i#install#i#/ s~.*~cat $JSON | jq -r .components.$c.install[]~e" centrallog/centralized-$c.tmpl.sh;
  sed -i -e "/#i#update#i#/ s~.*~cat $JSON | jq -r '.dist_upgrade.install[]'~e" centrallog/centralized-$c.tmpl.sh;
done

for l in $(cat $JSON |jq -r '.hosts[1].distributed[]'); do
  c=$(echo $l | cut -d':' -f1); C=$( echo $c | tr 'a-z' 'A-Z' );
  d=$(cat $JSON | jq -r ".components.$c.desc");
  n=$(cat $JSON | jq -r ".components.$c.name");
  v=$(cat $JSON | jq -r ".components.$c.version");
  
  echo "hostd|$v|$n|$d";
  
  sed -e "s/xgenericx/$n/g" \
      -e "s/XGENERICX/$C/g" \
      -e "s/0.0.0/$v/g" \
      -e "s/xlicensex/@License/g" \
      centrallog/centralized-generic.rfu.sh > centrallog/distributed-$c.tmpl.sh;
      
  sed -i -e "/#i#install#i#/ s~.*~cat $JSON | jq -r .components.$c.install[]~e" centrallog/distributed-$c.tmpl.sh;
  sed -i -e "/#i#update#i#/ s~.*~cat $JSON | jq -r '.dist_upgrade.install[]'~e" centrallog/distributed-$c.tmpl.sh;
done

rm -f *.sh~

exit 0

# Ard0ise
clone_dir=/tmp/KataScript-build-$$;
git clone https://github.com/Ardoise/KataScript.git $clone_dir;
$clone_dir/sh/centrallog/centralized-centrallog.tmpl.sh;
echo "rm -rf $clone_dir";
echo "unset clone_dir";
