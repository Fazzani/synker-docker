#!/bin/bash
set -e

echo "Remove deployed script"
ssh -o "StrictHostKeyChecking no" $REMOTE_USER@$REMOTE_HOST "rm -Rf /home/$REMOTE_USER/synker-docker" || true

rm *.tar
rm *.md

echo "Copy scripts to remote host"
scp -o "StrictHostKeyChecking no" -r $TRAVIS_BUILD_DIR $REMOTE_USER@$REMOTE_HOST:/home/$REMOTE_USER

echo "Setting env var on the remote machine"
printenv | grep -iv -e travis -e rvm -e ^_ > sshenv
scp sshenv $REMOTE_USER@$REMOTE_HOST:~/.ssh/environment

sleep 1

echo "Make excutable script"
ssh -o "StrictHostKeyChecking no" $REMOTE_USER@$REMOTE_HOST "chmod +x /home/$REMOTE_USER/synker-docker/deploy-travis/*.sh"

# For elasticsearch install
ssh -o "StrictHostKeyChecking no" $REMOTE_USER@$REMOTE_HOST "sudo sysctl -w vm.max_map_count=262144"

echo "Run up docker stack script"
ssh -o "StrictHostKeyChecking no" $REMOTE_USER@$REMOTE_HOST "/home/$REMOTE_USER/synker-docker/deploy-travis/runup.sh"

exit 0