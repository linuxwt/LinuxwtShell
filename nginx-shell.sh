#!/bin/bash

# chkconfig: - 85 15
# description: nginx is a high performance web server and proxy server 

# the next contents are relevant paths and variables of the  nginx
nginx_command=/usr/local/Nginx/sbin/nginx
nginx_config=/usr/local/Nginx/conf/nginx.conf
nginx_pid=/usr/local/Nginx/logs/nginx.pid
prog="nginx"
RETVAL=0

# start the usage of the scripts :/etc/init.d/functions
. /etc/rc.d/init.d/functions
# start network
. /etc/sysconfig/network
# check the NETWORKING 
[ ${NETWORKING} = "no" ] && exit 0
# check the nginx command can be excute
[ -x ${nginx_command} ] || exit 0

# set up the functions of start,stop,reload
start() {
	if [ -e ${nginx_pid} ];then
		echo -n "nginx is already running"
		exit 1
	fi
	echo -n "Startingprog: "
	daemon ${nginx_command} -c ${nginx_config}
	RETVAL=$?
	echo
	[ $RETVAL -eq 0 ] && touch /var/lock/subsys/nginx
	return $RETVAL
}
stop() {
	echo -n "Stoppingprog: "
	killproc ${nginx_command}
	RETVAL=$?
	echo
	[ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/nginx ${nginx_pid}
	return $RETVAL
}
reload() {
	echo -n "Reloadingprog: "
	killproc ${nginx_command} -HUP
	RETVAL=$?
	echp
}


# See how we were called
case "$1" in 
start)
	start
	;;
stop)
	stop
	;;
reload)
	reload
	;;
restart)
	stop
	start
	;;
status)
	status $prog
	RETVAL=$?
	;;
*)
	echo "Usage:prog {start|stop|reload|restart|status|help}"
	exit 1
esac
exit $RETVAL
