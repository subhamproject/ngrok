#!/bin/bash

docker run -it -e NGROK_AUTHTOKEN=XXXX ngrok/ngrok http 80
