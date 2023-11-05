#!/bin/bash

###############################################################################
### PLEASE NOTE YOU CAN'T EXPOSE MORE THAN 3 PORTS WITH NGROK FREE ACCOUNT    #
###############################################################################

TOKEN=$(ngrok config check | awk '{print $NF}'|xargs cat |grep auth|cut -d':' -f2|tr -d ' ')
envsubst << EOF > multi-expose.yaml
# in ngrok.yml
authtoken: $TOKEN
version: 2
log_level: info
log_format: json
log: /tmp/ngrok.log
region: ap #in
tunnels:
  first:
    addr: 3000
    proto: http
  second:
    addr: 9090
    proto: http
  third:
    addr: 9000
    proto: http
EOF

# Start NGROK in background
echo "⚡️ Starting ngrok"
ngrok start --config multi-expose.yaml --all > /dev/null &

# Wait for ngrok to be available
while ! nc -z localhost 4040; do
  printf 'Waiting for ngrok to be up..'
  sleep 5 # wait Ngrok to be available
done
echo " OK"

NGROK_REMOTE_URL="$(curl -s http://localhost:4040/api/tunnels | jq ".tunnels[].public_url")"
if test -z "${NGROK_REMOTE_URL}"
then
  echo "❌ ERROR: ngrok doesn't seem to return a valid URL (${NGROK_REMOTE_URL})."
  exit 1
fi

NGROK_REMOTE_URL=$(echo ${NGROK_REMOTE_URL} | tr -d '"')
NGROK_REMOTE_URL=${NGROK_REMOTE_URL/http:\/\//https:\/\/}

while IFS= read -r line ;
do
bold=$(tput bold)
normal=$(tput sgr0)
printf "\n\n🌍 Your ngrok remote URL are 👉 ${bold}${line} 👈\n📋 ${normal}\n"
done <<< "$NGROK_REMOTE_URL"
