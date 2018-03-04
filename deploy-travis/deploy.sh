#!/bin/bash

set -euox

scp -o "StrictHostKeyChecking no" -r $TRAVIS_BUILD_DIR $USER@$SERVER_IP:/home/$USER

sleep 1

ssh -o "StrictHostKeyChecking no" $USER@$SERVER_IP "chmod +x /home/$USER/synker-docker/deploy-travis/*.sh"

ssh -o "StrictHostKeyChecking no" $USER@$SERVER_IP 'bash -s' < ./deploy-travis/runup.sh

exit 0