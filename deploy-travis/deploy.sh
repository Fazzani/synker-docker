#!/bin/bash

set +e 
tar -czf package.tgz $TRAVIS_BUILD_DIR
exitcode=$?

if [ "$exitcode" != "1" ] && [ "$exitcode" != "0" ]; then
    exit $exitcode
fi
set -euox

ls
scp -o "StrictHostKeyChecking no" package.tgz $USER@$SERVER_IP:/home/dockeradmin/synker-docker/package.tgz