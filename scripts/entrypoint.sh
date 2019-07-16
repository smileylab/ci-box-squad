#!/bin/sh

sleep 20 # fixme
/usr/sbin/rabbitmq-server &
python3 /root/create_backend_lava.py &
su squad
squad --fast --bind 0.0.0.0:${SQUAD_PORT} &
squad-worker &
squad-scheduler &
squad-listener
