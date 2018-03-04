#!/bin/bash

set -euox

scp -o "StrictHostKeyChecking no" -r $TRAVIS_BUILD_DIR $USER@$SERVER_IP:/home/$USER

sleep 1

chmod +x deploy-travis/*.sh

./deploy-travis/runup.sh

exit 0