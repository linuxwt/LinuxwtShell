#!/bin/bash

# chkconfig: - 85 15

# description: Rinetd is an HTTP(S) server, HTTP(S) reverse proxy and IMAP/POP3 proxy server

# processname: rinetd

# config: /etc/rinetd.conf

# pidfile: /var/lock/subsys/rinetd

# Source function library.

. /etc/rc.d/init.d/functions

  

# Source networking configuration.

. /etc/sysconfig/network

  

# Check that networking is up.

[ "$NETWORKING" = "no" ] && exit 0

  

rinetd="/usr/sbin/rinetd"

prog=$(basename $rinetd)

  

RINETD_CONF_FILE="/etc/rinetd.conf"

  

#[ -f /etc/sysconfig/rinetd ] && . /etc/sysconfig/rinetd

  

lockfile=/var/lock/subsys/rinetd

  

start() {

    [ -x $rinetd ] || exit 5

    [ -f $RINETD_CONF_FILE ] || exit 6

    echo -n $"Starting $prog: "

    daemon $rinetd -c $RINETD_CONF_FILE

    retval=$?

    echo

    [ $retval -eq 0 ] && touch $lockfile

    return $retval

}

  

stop() {

    echo -n $"Stopping $prog: "

    #killproc $rinetd -HUP

    daemon pkill $prog

    retval=$?

    echo

    [ $retval -eq 0 ] && rm -f $lockfile

    return $retval

}

  

restart() {

    stop

    sleep 1

    start

}

  

reload() {

    echo -n $"Reloading $prog: "

    killproc $rinetd -HUP

    RETVAL=$?

    echo

}

  

rh_status() {

    status $prog

}

rh_status_q() {

    rh_status >/dev/null 2>&1

}

  

case "$1" in

    start)

        rh_status_q && exit 0

        $1

        ;;

    stop)

        rh_status_q || exit 0

        $1

        ;;

    restart)

        $1

        ;;

    reload)

        rh_status_q || exit 7

        $1

        ;;

    status)

        rh_status

        ;;

    *)

        echo $"Usage: $0 {start|stop|status|restart|reload}"

        exit 2

esac
