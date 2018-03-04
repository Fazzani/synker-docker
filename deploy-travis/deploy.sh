#!/bin/bash

set +e 
scp -o "StrictHostKeyChecking no" -r $TRAVIS_BUILD_DIR $USER@$SERVER_IP:/home/dockeradmin