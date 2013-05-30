#!/bin/bash

cat <<EOF >standalone-jre.config.sh
#!/bin/sh

case $@ in
*ubuntu*)
  cd ~;
  sudo apt-get update;
  sudo apt-get install openjdk-7-jre-headless -y;
;;
*redhat*)
  echo "not yet";
;;
*)
  echo "not yet";
;;
cat <<EOF >standalone-jre.config.sh
EOF
