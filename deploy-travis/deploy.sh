#!/bin/bash
set -e

echo "Remove deployed script"
ssh -o "StrictHostKeyChecking no" $REMOTE_USER@$REMOTE_HOST "rm -R /home/$REMOTE_USER/synker-docker" || true

echo "Copy scripts to remote host"
scp -o "StrictHostKeyChecking no" -r $TRAVIS_BUILD_DIR $REMOTE_USER@$REMOTE_HOST:/home/$REMOTE_USER

sleep 1

echo "Make excutable script"
ssh -o "StrictHostKeyChecking no" $REMOTE_USER@$REMOTE_HOST "chmod +x /home/$REMOTE_USER/synker-docker/deploy-travis/*.sh"

echo "Run up docker stack script"
echo "$MYSQL_PASSWORD" > /home/$REMOTE_USER/tmp.txt
echo "$MYSQL_ROOT_PASSWORD" > /home/$REMOTE_USER/tmp2.txt
ssh -o "StrictHostKeyChecking no" $REMOTE_USER@$REMOTE_HOST 'bash -s' < ./deploy-travis/runup.sh $REMOTE_USER $MYSQL_PASSWORD $MYSQL_ROOT_PASSWORD $MYSQL_DATABASE $MYSQL_RESET_DATABASE

exit 0