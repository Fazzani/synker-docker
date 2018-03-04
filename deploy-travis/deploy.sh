#!/bin/bash

set -euox

scp -o "StrictHostKeyChecking no" -r $TRAVIS_BUILD_DIR $USER@$SERVER_IP:/home/$USER

sleep 1

ssh $REMOTE_USER@$REMOTE_HOST chmod +x /home/$USER/synker-docker/deploy-travis/*.sh

ssh $REMOTE_USER@$REMOTE_HOST 'bash -s' < ./deploy-travis/runup.sh

exit 0