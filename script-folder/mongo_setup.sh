#!/usr/bin/env bash

echo 'Creating application user and db'

mongo ${MONGO_INITDB_DATABASE:-synkerdb} \
        -u ${MONGO_INITDB_ROOT_USERNAME:-admin} \
        -p ${MONGO_INITDB_ROOT_PASSWORD:-password} \
        --authenticationDatabase admin \
        --eval "db.createUser({user: '${DATABASE_USERNAME:-pl}', pwd: '${DATABASE_PASSWORD:-password}', roles:[{role:'dbOwner', db: '${MONGO_INITDB_DATABASE:-synkerdb}'}]});"