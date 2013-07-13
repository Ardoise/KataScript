#!/bin/sh -e

group=${gid:lab-devops};
gid=${gid:lab-guest};
uid=${uid:lab-guest};
pass=${pass:lab-guest};
$action=${get:get};

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

case $action in
get)
  id -a $uid
;;
put|post)
  sudo groupadd -r $gid || true;
  sudo useradd --gid $gid --groups $groups --password $pass $uid || true;
  sudo usermod -a -G $groups $uid || true;
;;
delete)
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
