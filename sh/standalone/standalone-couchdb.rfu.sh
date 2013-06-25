#!/bin/bash
### BEGIN INIT INFO
# Provides: standalone: couchdb
# Short-Description: DEPLOY SERVER: [STORAGESEARCH]
# Author: created by: https://github.com/Ardoise
# Update: last-update: 20130615
### END INIT INFO

# Description: SERVICE STANDALONE: couchdb (NoSQL, INDEX, SEARCH)
# - deploy couchdb v2.4.4
#
# Requires : you need root privileges tu run this script
# Requires : curl
#
# CONFIG:   [ "/etc/couchdb", "/etc/couchdb/test" ]
# BINARIES: [ "/opt/couchdb/", "/usr/share/couchdb/" ]
# LOG:      [ "/var/log/couchdb/" ]
# RUN:      [ "/var/couchdb/couchdb.pid" ]
# INIT:     [ "/etc/init.d/couchdb" ]

set -e

NAME=couchdb
DESC="couchdb Server"
DEFAULT=/etc/default/$NAME

if [ `id -u` -ne 0 ]; then
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: You need root privileges to run this script"
  exit 1
fi

cat <<-'EOF' >standalone-couchdb.getbin.sh
#!/bin/sh

[ -d "/opt/couchdb" ] || sudo mkdir -p /opt/couchdb;
[ -d "/etc/couchdb" ] || sudo mkdir -p /etc/couchdb;

SITE=http://downloads-distro.couchdb.org/

SYSTEM=`/bin/uname -s`;
if [ $SYSTEM = Linux ]; then
  DISTRIB=`cat /etc/issue`
fi

case $DISTRIB in
Ubuntu*|Debian*)
  echo "apt-get update";
  sudo apt-get install couchdb
;;
Red*Hat*)
  sudo yum install couchdb
;;
*)
 : 
;;
esac

EOF
chmod a+x standalone-couchdb.getbin.sh


cat <<EOF >standalone-couchdb.sh
echo "view /etc/couchdb/couchdb.conf"
echo "sudo service couchdb stop";
echo "sudo service couchdb start";
echo "sudo service couchdb restart";
/etc/init.d/couchdb status
/etc/init.d/couchdb force-reload
/etc/init.d/couchdb restart
EOF


cat <<'EOF' >standalone-couchdb.test.sh

EOF
chmod +x standalone-couchdb.test.sh


cat <<'EOF' >etc-init.d-ucouchdb
#!/bin/sh -e

# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

### BEGIN INIT INFO
# Provides:          couchdb
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Apache CouchDB init script
# Description:       Apache CouchDB init script for the database server.
### END INIT INFO

SCRIPT_OK=0
SCRIPT_ERROR=1

DESCRIPTION="database server"
NAME=couchdb
SCRIPT_NAME=`basename $0`
COUCHDB=/usr/bin/couchdb
CONFIGURATION_FILE=/etc/default/couchdb
RUN_DIR=/var/run/couchdb
LSB_LIBRARY=/lib/lsb/init-functions

if test ! -x $COUCHDB; then
    exit $SCRIPT_ERROR
fi

if test -r $CONFIGURATION_FILE; then
    . $CONFIGURATION_FILE
fi

log_daemon_msg () {
    # Dummy function to be replaced by LSB library.

    echo $@
}

log_end_msg () {
    # Dummy function to be replaced by LSB library.

    if test "$1" != "0"; then
      echo "Error with $DESCRIPTION: $NAME"
    fi
    return $1
}

if test -r $LSB_LIBRARY; then
    . $LSB_LIBRARY
fi

run_command () {
    command="$1"
    if test -n "$COUCHDB_OPTIONS"; then
        command="$command $COUCHDB_OPTIONS"
    fi
    if test -n "$COUCHDB_USER"; then
        if su $COUCHDB_USER -c "$command"; then
            return $SCRIPT_OK
        else
            return $SCRIPT_ERROR
        fi
    else
        if $command; then
            return $SCRIPT_OK
        else
            return $SCRIPT_ERROR
        fi
    fi
}

start_couchdb () {
    # Start Apache CouchDB as a background process.

    test -e "$RUN_DIR" || \
        install -m 755 -o "$COUCHDB_USER" -g "$COUCHDB_USER" -d "$RUN_DIR"
    command="$COUCHDB -b"
    if test -n "$COUCHDB_STDOUT_FILE"; then
        command="$command -o $COUCHDB_STDOUT_FILE"
    fi
    if test -n "$COUCHDB_STDERR_FILE"; then
        command="$command -e $COUCHDB_STDERR_FILE"
    fi
    if test -n "$COUCHDB_RESPAWN_TIMEOUT"; then
        command="$command -r $COUCHDB_RESPAWN_TIMEOUT"
    fi
    run_command "$command" > /dev/null
}

stop_couchdb () {
    # Stop the running Apache CouchDB process.

    run_command "$COUCHDB -d" > /dev/null
    RET=1;
    for i in $(seq 1 30); do
        status=`$COUCHDB -s 2>/dev/null | grep -c process`;
        if [ "$status" -eq 0 ]; then
            RET=0;
            break;
        fi;
        echo -n .;
        sleep 1s;
    done;
    return $RET
}

display_status () {
    # Display the status of the running Apache CouchDB process.

    run_command "$COUCHDB -s"
}

parse_script_option_list () {
    # Parse arguments passed to the script and take appropriate action.

    case "$1" in
        start)
            log_daemon_msg "Starting $DESCRIPTION" $NAME
            if start_couchdb; then
                log_end_msg $SCRIPT_OK
            else
                log_end_msg $SCRIPT_ERROR
            fi
            ;;
        stop)
            log_daemon_msg "Stopping $DESCRIPTION" $NAME
            if stop_couchdb; then
                log_end_msg $SCRIPT_OK
            else
                log_end_msg $SCRIPT_ERROR
            fi
            ;;
        restart|force-reload)
            log_daemon_msg "Restarting $DESCRIPTION" $NAME
            if stop_couchdb; then
                if start_couchdb; then
                    log_end_msg $SCRIPT_OK
                else
                    log_end_msg $SCRIPT_ERROR
                fi
            else
                log_end_msg $SCRIPT_ERROR
            fi
            ;;
        status)
            display_status
            ;;
        *)
            cat << EOF >&2
Usage: $SCRIPT_NAME {start|stop|restart|force-reload|status}
EOF
            exit $SCRIPT_ERROR
            ;;
    esac
}

parse_script_option_list $@


EOF
chmod +x etc-init.d-ucouchdb

exit 0
