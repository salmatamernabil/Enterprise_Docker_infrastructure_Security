#!/bin/sh
export RABBITMQ_DEFAULT_USER="$(cat /run/secrets/rabbitmq_user 2>/dev/null || echo "$RABBITMQ_USER")"
export RABBITMQ_DEFAULT_PASS="$(cat /run/secrets/rabbitmq_password)"
exec docker-entrypoint.sh rabbitmq-server
