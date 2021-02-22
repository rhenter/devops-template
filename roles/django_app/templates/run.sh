#!/bin/sh
#
### BEGIN INIT INFO
# Provides:          {{ company_slug }}-{{ app_name }}
# Required-Start:    $syslog $remote_fs
# Should-Start:      $time ypbind smtp
# Required-Stop:     $syslog $remote_fs
# Should-Stop:       ypbind smtp
# Default-Start:     3 5
# Default-Stop:      0 1 2 6
### END INIT INFO

# Source function library.
. /lib/init/vars.sh
. /lib/lsb/init-functions

inifile="/opt/{{ company_slug }}/conf/{{ app_name }}/uwsgi.ini"
lockfile="/opt/{{ company_slug }}/logs/{{ app_name }}/uwsgi.pid"
UWSGI_OPTIONS="--die-on-term --ini $inifile"

# Check for missing binaries (stale symlinks should not happen)
UWSGI_BIN="/opt/{{ company_slug }}/{{ app_name }}/bin/uwsgi"

test -x $UWSGI_BIN || { echo "$UWSGI_BIN not installed";
        if [ "$1" = "stop" ]; then exit 0;
        else exit 5; fi; }

case "$1" in
    start)
        echo -n "Starting {{ service_title }}"
        start-stop-daemon --start --quiet --pidfile $lockfile --exec $UWSGI_BIN -- $UWSGI_OPTIONS
        ;;
    stop)
        echo -n "Shutting down {{ service_title }}"
        start-stop-daemon --stop --quiet --pidfile $lockfile
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    status)
        echo -n "Checking for service {{ service_title }}"
        status -p $lockfile $UWSGI_BIN
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac
exit 0
