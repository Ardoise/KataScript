#!/bin/sh -e

groups=${gid:-admin};
gid=${gid:-devops};
uid=${uid:-devops};
pass=${pass:-devops};
$action=${pass:-get};

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
  case $gid,$uid in
    admin,admin|admin,devops|devops,devops)
      :    
    ;;
    devops,*|admin,*)
      sudo userdel $uid || true;
    ;;
    *,*)
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
