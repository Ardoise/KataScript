#!/bin/bash -e

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
for l in $(cat $JSON |jq -r -c '.Profil[]' |grep 'software'); do

  i=$(echo $l | jq -r '.id'); echo -n "$i|";
  s=$(echo $l | jq -r '.software'); echo -n "$s|";
  e=$(echo $l | jq -r '.platform'); echo -n "$e|";
  p=$(echo $l | jq -r '.bin'); echo -n "$p|";
  c=$(echo $l | jq -r '.conf'); echo -n "$c|";
  g=$(echo $l | jq -r '.log'); echo -n "$g|";
  r=$(echo $l | jq -r '.run'); echo -n "$r|";
  
  n=$(cat $JSON | jq -r -c ".software.$s.name"); echo -n "$n|";
  N=$( echo $n | tr 'a-z' 'A-Z' ); echo -n "$N|";
  d=$(cat $JSON | jq -r -c ".software.$s.desc"); echo -n "$d|";
  v=$(cat $JSON | jq -r -c ".software.$s.version"); echo -n "$v|";
  b=$(cat $JSON | jq -r -c ".software.$s.binary"); echo -n "$b|";
  u=$(cat $JSON | jq -r -c ".software.$s.download"); echo -n "$u|";
  
  Daemon=$(cat $JSON | jq -r -c .process.$i.Daemon.On); echo -n "$Daemon|";
  NoDaemon=$(cat $JSON | jq -r -c .process.$i.Daemon.Off); echo -n "$NoDaemon|";
  hi=$(cat $JSON | jq -r -c .process.$i.reload.input);  echo -n "$hi|";
  ho=$(cat $JSON | jq -r -c .process.$i.reload.output); echo -n "$ho|";
  
  echo
  [ -f "$tmp/centralized-generic.rfu.sh.1" ] && (\
  sed -e "s~xgenericx~$n~g" \
      -e "s~XGENERICX~$N~g" \
      -e "s~0.0.0~$v~g" \
      -e "s~#i#binary#i#~$b~g" \
      -e "s~#i#bin#i#~$p~g" \
      -e "s~#i#download#i#~$u~g" \
      -e "s~#i#daemon#i#~$Daemon~g" \
      -e "s~#i#nodaemon#i#~$NoDaemon~g" \
      -e "s~xlicensex~@License~g" \
      $tmp/centralized-generic.rfu.sh.1 > $tmp/$e-$n.tmpl.sh.2);
  
  [ -f "$tmp/$e-$n.tmpl.sh.2" ] && (\
  sed -e "/#i#start#i#/ s~.*~cat $JSON | jq -r .process.$i.start~e" \
      -e "/#i#status#i#/ s~.*~cat $JSON | jq -r .process.$i.status~e" \
      -e "/#i#stop#i#/ s~.*~cat $JSON | jq -r .process.$i.stop~e" \
      -e "/#i#pconfig#i#/ s~.*~cat $JSON | jq -r '\"PATTERN_FILE=\"+.process.$i.reload.pattern'~e" \
      -e "/#i#config#i#/ s~.*~cat $JSON | jq -r '\"CONF_FILE=\"+.process.$i.reload.conf'~e" \
      $tmp/$e-$n.tmpl.sh.2 > centrallog/$e-$n.tmpl.sh);

  #sed -i -e "/#i#update#i#/ s~.*~cat $JSON | jq -r '.dist_upgrade.install[]'~e" centrallog/centralized-$n.tmpl.sh;
done

rm -f *.sh~

exit 0

# ===================
# RUN GLOBAL CONTEXT
# ===================
dpkg -i http://files.vagrantup.com/packages/b12c7e8814171c1295ef82416ffe51e8a168a244/vagrant_1.3.1_x86_64.deb
###############################
#vagrant box add {title} {url}
#vagrant init {title}
#vagrant up
# box: http://www.vagrantbox.es/
# Ubuntu precise VirtualBox
#vagrant box add base http://files.vagrantup.com/precise32.box
#vagrant box add base http://files.vagrantup.com/precise64.box
###############################
vagrant box add base http://files.vagrantup.com/precise32.box
vagrant init base
vagrant up
vagrant ssh

sudo apt-get update       #soft
sudo apt-get upgrade      #system
sudo apt-get dist-upgrade #kernel
sudo apt-get autoremove   #purge
sudo apt-get -y install curl git-core sudo 

clone_dir=/tmp/KataScript-build-$$;
git clone https://github.com/Ardoise/KataScript.git $clone_dir;
sudo sh $clone_dir/sh/centrallog/centralized-centrallog.tmpl.sh dist-upgrade;
sudo sh $clone_dir/sh/centrallog/centralized-centrallog.tmpl.sh install;
echo "rm -rf $clone_dir";
echo "unset clone_dir";
