#!/bin/sh -e

if [ -f "~/.ssh/config" ]; then
  ssh -F ~/.ssh/config $@;        #per-user configuration file
elif [ -f "/etc/ssh/ssh_config" ]; then
  ssh -F /etc/ssh/ssh_config $@;  #system-wide configuration file
else
  ssh $@;
fi

exit 0
