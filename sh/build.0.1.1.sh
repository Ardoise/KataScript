#!/bin/sh -e

PROGNAME=${0##*/}; echo $PROGNAME;
VERSION="0.0.0"; echo $VERSION;
DATE=$(date +'%Y-%m-%d'); echo $DATE;
AUTHOR=`id -un`;
[ -f "/etc/passwd" ] && AUTHOR=$(awk -v USER=$USER 'BEGIN { FS = ":" } $1 == USER { print $5 }' < /etc/passwd);
echo $AUTHOR;
tmp="/tmp";
[ -d "$tmp" ] || mkdir -p $tmp;
EMAIL_ADDRESS="<${REPLYTO:-${USER}@$HOSTNAME}>"; echo $EMAIL_ADDRESS

cat <<-_EOF_ >licence.txt
	# This program is free Software: you can redistribute it and/or modify
	# it under the terms of the GNU General Public License as published by
	# the Free Software Foundation, either version 3 of the License, or
	# (at your option) any later version.

	# This program is distributed in the hope that it will be useful,
	# but WITHOUT ANY WARRANTY; without even the implied warranty of
	# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	# GNU General Public License at (http://www.gnu.org/licenses/) for
	# more details.
_EOF_

# ===================
# LOAD GLOBAL CONTEXT
# ===================
# JSON => GlobalENV
JSON=json/cloud.json
for l in $(cat $JSON |jq -r -c '.Profil.Dir'); do
  Bin=$(echo $l | jq -r '.Bin'); echo "$Bin";        Bin=${Bin:-="/opt/"};
  Cache=$(echo $l | jq -r '.Cache'); echo "$Cache";  Cache=${Cache:-="/var/cache/"};
  Etc=$(echo $l | jq -r '.Etc'); echo "$Etc";        Etc=${Etc:-="/etc/"};
  Lib=$(echo $l | jq -r '.Lib'); echo "$Lib";        Lib=${Lib:-="/var/lib/"};
  Log=$(echo $l | jq -r '.Log'); echo "$Log";        Log=${Log:-="/var/log/"};
  Run=$(echo $l | jq -r '.Run'); echo "$Run";        Run=${Run:-="/var/run/"};
done


# GlobalENV + TEMPLATE => TEMPLATE.1
[ -f "centrallog/centralized-generic.rfu.sh" ] && (\
sed -e "s~#i#DirBin#i#~$Bin~g" \
    -e "s~#i#DirCache#i#~$Cache~g" \
    -e "s~#i#DirEtc#i#~$Etc~g" \
    -e "s~#i#DirLib#i#~$Lib~g" \
    -e "s~#i#DirLog#i#~$Log~g" \
    -e "s~#i#DirRun#i#~$Run~g" \
    centrallog/centralized-generic.rfu.sh > $tmp/centralized-generic.rfu.sh.1);

# ===================
# LOAD local CONTEXT
# ===================
# JSON => LocalENV
# LocalENV + TEMPLATE.1 => TEMPLATE.2 => RFU
JSON=json/cloud.json
for l in $(cat $JSON |jq -r -c '.Profil[]' |grep 'Software'); do

  id=$(echo $l | jq -r '.id'); echo -n "$id|";
  soft=$(echo $l | jq -r '.Software'); echo -n "$soft|";
  Platform=$(echo $l | jq -r '.Platform'); echo -n "$Platform|";
  
  name=$(cat $JSON | jq -r -c ".Software.$soft.name"); echo -n "$name|";
  NAME=$( echo $name | tr 'a-z' 'A-Z' ); echo -n "$NAME|";
  title=$(cat $JSON | jq -r -c ".Software.$soft.title"); echo -n "$title|"; # NotUSE
  version=$(cat $JSON | jq -r -c ".Software.$soft.version"); echo -n "$version|";
  download=$(cat $JSON | jq -r -c ".Software.$soft.download"); echo -n "$download|";
  
  Daemon=$(cat $JSON | jq -r -c .process.$id.Daemon.On); echo -n "$Daemon|";
  NoDaemon=$(cat $JSON | jq -r -c .process.$id.Daemon.Off); echo -n "$NoDaemon|";
  hi=$(cat $JSON | jq -r -c .process.$id.init.input);  echo -n "$hi|";
  ho=$(cat $JSON | jq -r -c .process.$id.init.output); echo -n "$ho|";
  
  echo
  [ -f "$tmp/centralized-generic.rfu.sh.1" ] && (\
  sed -e "s~xgenericx~$name~g" \
      -e "s~XGENERICX~$NAME~g" \
      -e "s~0.0.0~$version~g" \
      -e "s~#i#download#i#~$download~g" \
      -e "s~#i#daemon#i#~$Daemon~g" \
      -e "s~#i#nodaemon#i#~$NoDaemon~g" \
      -e "s~xlicensex~@License~g" \
      $tmp/centralized-generic.rfu.sh.1 > $tmp/$Platform-$name.tmpl.sh.2);
  
  [ -f "$tmp/$Platform-$name.tmpl.sh.2" ] && (\
  sed -e "/#i#start#i#/ s~.*~cat $JSON | jq -r .process.$id.start~e" \
      -e "/#i#status#i#/ s~.*~cat $JSON | jq -r .process.$id.status~e" \
      -e "/#i#stop#i#/ s~.*~cat $JSON | jq -r .process.$id.stop~e" \
      -e "/#i#pconfig#i#/ s~.*~cat $JSON | jq -r '\"PATTERN_FILE=\"+.process.$id.init.pattern'~e" \
      -e "/#i#config#i#/ s~.*~cat $JSON | jq -r '\"CONF_FILE=\"+.process.$id.init.conf'~e" \
      $tmp/$Platform-$name.tmpl.sh.2 > centrallog/$Platform-$name.tmpl.sh);

done

rm -f *.sh~

exit 0