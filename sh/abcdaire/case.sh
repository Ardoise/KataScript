#!/bin/sh
########################################################################
# Begin myprogramm
#
# Description : myprogramm
#
# Authors     : Ardoise - ardoise.gisement@gmail.com
#               Ardoise - ardoise.gisement@github.com
# Update      : Ardoise - ardoise.gisement@github.com
#
# Version     : xyz 0.1.0
#
########################################################################

### BEGIN INIT INFO
# Provides:            myprogramm
# Required-Start:      $local_fs
# Should-Start:
# Required-Stop:
# Should-Stop:
# Default-Start:       S
# Default-Stop:        0 6
# Short-Description:   bla bla.
# Description:         bla bla
#                      ... .
### END INIT INFO

. /lib/lsb/init-functions
[ -r /.... ] && . /....

case "${1}" in
  start)
    log_info_msg "bla bla..."
    ...
    evaluate_retval

    log_info_msg "bla bla..."
    hostname ${HOSTNAME}
    evaluate_retval
    ;;

  stop)
    log_info_msg "bla bla..."
    ...
    evaluate_retval
    ;;
  restart)
    ${0} stop
    sleep 1
    ${0} start
    ;;
  *)
    echo "Usage: ${0} {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0

# End myprogramm
