#!/bin/sh
export JDBC_PASSWORD="$(cat /run/secrets/db_password)"
export RABBITMQ_PASSWORD="$(cat /run/secrets/rabbitmq_password)"
exec catalina.sh run
