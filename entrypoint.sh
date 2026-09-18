#!/bin/bash
cd /home/container || exit 1

# Print java version for the console/log, helpful for debugging
echo -e "java -version\n"
java -version

# Wings injects all Egg "environment variables" as real env vars, and
# passes the rendered STARTUP command in the STARTUP env var with the
# {{VAR}} placeholders already... actually NOT rendered - Wings renders
# {{VAR}} itself before calling this, but as a safety net we also do it
# here in case this image is run standalone (e.g. via `docker run`).
MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# shellcheck disable=SC2086
eval "${MODIFIED_STARTUP}"
