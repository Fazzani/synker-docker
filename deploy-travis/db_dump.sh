#!/bin/bash

function purge() {
    files_pattern_to_delete=${1:*.log}
    retention={$2:-3}
    find $lo -type f -mtime +7 -exec /bin/rm -f {} \;
}

#SYNKER DB DUMP
db_user=${1:-pl}
database=${2:-playlist}

dump_filename="dump_${database}_$(date +%F).sql"
local_dump_file_path="/mnt/nfs/postgres/data/$dump_filename"

sudo docker exec -i $(sudo docker ps -aq -f "name=synker_synkerdb") \
/bin/bash -c "pg_dump -U $db_user $database > /var/lib/postgresql/data/${dump_filename}"

[ -f $local_dump_file_path ] || exit -1

gzip -f $local_dump_file_path

exit 0
