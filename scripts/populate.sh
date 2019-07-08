#!/bin/sh

handler() {
	exit 0
}

trap 'handler' INT QUIT TERM

if [ ${#} -ne 3 ]; then
	echo "usage: ${0} <username> <password> <email>"
	exit 1
fi

squad --bind 0.0.0.0:${SQUAD_PORT} &

#fixme
sleep 20

squad-admin createsuperuser --noinput --username ${1} --email ${3} || true
ADMIN_TOKEN_STRING=$(squad-admin drf_create_token ${1})
ADMIN_TOKEN=$(echo ${ADMIN_TOKEN_STRING} | cut -d ' ' -f 3)

for project in ${SQUAD_PROJECTS} ; do
  python3 /root/create_project.py --url http://localhost:${SQUAD_PORT}/api/ --token "${ADMIN_TOKEN}" --group ${SQUAD_GROUP} --project ${project}
done

# Add lava backend if any
if [ -n "${LAVA_SERVER}" ]; then
	python3 /root/create_backend_lava.py --url http://localhost:${SQUAD_PORT}/api/ --token "${ADMIN_TOKEN}" --lava-url http://${LAVA_SERVER}/RPC2 --lava-token ${LAVA_TOKEN} --lava-username ${LAVA_USERNAME}
fi

exit 0
