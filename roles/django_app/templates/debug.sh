#!/bin/bash

enable-debug() {
    app=$(echo $1);

    inifile="/opt/{{ company_slug }}/conf/${app}/uwsgi.ini"

    sed -i 's/daemonize/# daemonize/g' $inifile
}
disable-debug() {
    app=$(echo $1);

    inifile="/opt/{{ company_slug }}/conf/${app}/uwsgi.ini"

    sed -i 's/# daemonize/daemonize/g' $inifile
}


runserver-debug() {
    app=$(echo $1);

    inifile="/opt/{{ company_slug }}/conf/${app}/uwsgi.ini"
    lockfile="/opt/{{ company_slug }}/${app}/logs/${app}-uwsgi.pid"
    uwsgi_options="--die-on-term --ini $inifile --honour-stdin"
    uwsgi_bin="/usr/sbin/uwsgi"

    echo -n "Shutting down ${app}"
    killproc -p $lockfile $uwsgi_bin

    echo -n "Running in debug mode..."

    $uwsgi_bin $uwsgi_options
}
