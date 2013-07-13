#!/bin/sh -e

group=${gid:lab-devops};
gid=${gid:lab-guest};
uid=${uid:lab-guest};
pass=${pass:lab-guest};

  : ${1?"Usage: $0 <HEAD|GET|PUT|DELETE|POST>"} # REST
  
case $uid in
  lab-*) : ;;
  *) uid=lab-${uid} ;;
esac
case $gid in
  lab-*) : ;;
  *) gid=lab-${gid} ;;
esac
case $group in
  lab-*) : ;;
  *) group=lab-${group} ;;
esac

case $1 in
get|GET)
  id -a $uid
;;
put|post|PUT|POST)
  sudo groupadd -r $gid || true;
  sudo useradd --gid $gid --groups $groups --password $pass $uid || true;
  sudo usermod -a -G $groups $uid || true;
;;
head|HEAD)
  echo "uid=65535(guest) gid=65535(guest) groups=65535(guest)";
;;
delete|DELETE)
  case $uid,$gid in
    lab-*,lab-devops)
      sudo userdel $uid || true;
    ;;  
    lab-*,lab-*)
      sudo userdel $uid || true;
      sudo userdel $gid || true;      
    ;;
  esac
;;
*)
  :
;;
esac

exit 0
