  log_info_msg "Reloading daemon ..."
    pid=`pidofproc mydaemon`
    kill -HUP "${pid}"
    evaluate_retval
