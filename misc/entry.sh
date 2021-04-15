#!/bin/bash
CONFIG="/app/config/config.yml"
GUNICORN_PORT=5000
GUNICORN_WORKERS=2
GUNICORN_THREADS=2

#Generate a unique secret key for flask
SECRET_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
sed -i "s/12345678901234567890/${SECRET_KEY}/" ${CONFIG}

sed -i -e "s/p-admin-user/${PROXYSQL_ADMIN_USER}/g" ${CONFIG}
sed -i -e "s/p-admin-password/${PROXYSQL_ADMIN_PASSWORD}/g" ${CONFIG}

echo
if [ -n "${WEBSERVER_PORT}" ]; then
    GUNICORN_PORT=${WEBSERVER_PORT}
fi

if [ -n "${WEBSERVER_WORKERS}" ]; then
    GUNICORN_WORKERS=${WEBSERVER_WORKERS}
fi

if [ -n "${WEBSERVER_THREADS}" ]; then
    GUNICORN_THREADS=${WEBSERVER_THREADS}
fi

gunicorn --chdir /app wsgi:app -w ${GUNICORN_WORKERS} --threads ${GUNICORN_THREADS} -b 0.0.0.0:${GUNICORN_PORT}

