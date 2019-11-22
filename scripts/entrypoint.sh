#!/bin/sh

sleep 20 # fixme
/usr/sbin/rabbitmq-server &
su squad
squad --fast --bind 0.0.0.0:${SQUAD_PORT} &
squad-worker &
squad-scheduler &
squad-listener
