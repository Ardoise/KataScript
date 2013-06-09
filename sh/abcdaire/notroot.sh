#!/bin/sh

ROOT_UID=0          # Only users with $UID 0 have root privileges.
E_NOTROOT=87        # Non-root exit error.
UID=${UID:-`id -u`}

# Run as root, of course.
if [ "$UID" -ne "$ROOT_UID" ];then
  echo "Must be root to run this script."
  exit $E_NOTROOT
fi


E_XCD=86        # Non-root exit error.
cd /var/log || {
 echo "Cannot change to necessary directory." >&2
 exit $E_XCD;
}

exit 0
#  A zero return value from the script upon exit indicates success
#+ to the shell.
