#!/bin/sh

set -ex

handler() {
	exit 0
}

trap 'handler' INT QUIT TERM

if [ ${#} -ne 4 ]; then
	echo "usage: ${0} <username> <password> <email> <token>"
	exit 1
fi

squad --bind 0.0.0.0:${SQUAD_PORT} &

#fixme
sleep 120

squad-admin users add --email ${3} --passwd ${2} --superuser ${1}
squad-admin users set-token ${1} ${4}

for project in ${SQUAD_PROJECTS} ; do
  python3 /root/create_project.py --url http://localhost:${SQUAD_PORT}/api/ --token "${4}" --group ${SQUAD_GROUP} --project ${project}
done

# Add lava backend if any
if [ -n "${LAVA_SERVER}" ]; then
	python3 /root/create_backend_lava.py --url http://localhost:${SQUAD_PORT}/api/ --token "${4}" --lava-url http://${LAVA_SERVER}/RPC2 --lava-token ${LAVA_TOKEN} --lava-username ${LAVA_USERNAME}
fi

exit 0
