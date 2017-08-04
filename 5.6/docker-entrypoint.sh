#!/bin/bash
set -e

if [ "$1" = "goreman" ]; then
	if [ -d /app/docker-entrypoint-init.d ]; then
        	for f in /app/docker-entrypoint-init.d/*.sh; do
			[ -f "$f" ] && . "$f" || true
		done
	fi
	exec "$@"
fi

exec "$@"
