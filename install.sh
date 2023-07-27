#!/bin/bash

SSH_SPEC="$1"
EMAIL="$2"
APP_PASS="$3"
ENABLE_LOG="$4"

scp remote-install.sh $SSH_SPEC:
ssh $SSH_SPEC "chmod u+x remote-install.sh; ./remote-install.sh $EMAIL $APP_PASS $ENABLE_LOG; rm remote-install.sh"

