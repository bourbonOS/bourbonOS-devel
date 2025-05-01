#!/bin/bash

USER_NAME=${CONTAINER_USER:-user}
USER_ID=${CONTAINER_UID:-1000}
GROUP_ID=${CONTAINER_GID:-1000}

if ! getent group "${GROUP_ID}" >/dev/null; then
	addgroup -g "${GROUP_ID}" "${USER_NAME}"
fi

if ! getent passwd "${USER_ID}" >/dev/null; then
	adduser -u "${USER_ID}" -G "${USER_NAME}" -D -s /bin/bash "${USER_NAME}"
	echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/"${USER_NAME}"
	chmod 0440 /etc/sudoers.d/"${USER_NAME}"
fi

if [ ! -d "/home/${USER_NAME}" ]; then
	mkdir -p "/home/${USER_NAME}"
	chown "${USER_ID}:${GROUP_ID}" "/home/${USER_NAME}"
fi

service ssh start

if [ $# -eq 1 ]; then
	if [ "$1" = "/usr/sbin/init" ]; then
		exec /usr/sbin/init
	else
		exec tail -f /dev/null
	fi
else
	if [ $# -eq 0 ]; then
		exec su - "${USER_NAME}"
	else
		exec su - "${USER_NAME}" -c "$*"
	fi
fi