#!/bin/bash

function purge() {
    files_pattern_to_delete=${1:*.gz}
    retentionMax={$2:-3}
    current_dir=${3:-.}

    files_count_to_delete="$(($(find $current_dir -name $files_pattern_to_delete -type f | wc -l) - $r))"
    rm -rf $(find $current_dir -name $files_pattern_to_delete -type f | sort -n | head -n $files_count_to_delete)
}

#SYNKER DB DUMP
db_user=${1:-pl}
database=${2:-playlist}

retention=5
dump_dir="/mnt/nfs/postgres/data/"
dump_filename="dump_${database}_$(date +%F).sql"
local_dump_file_path="${dump_dir}${dump_filename}"

sudo docker exec -i $(sudo docker ps -aq -f "name=synker_synkerdb") \
/bin/bash -c "pg_dump -U $db_user $database > /var/lib/postgresql/data/${dump_filename}"

[ -f $local_dump_file_path ] || exit -1

echo "Compressiong dump"
gzip -f $local_dump_file_path

echo "Purging dumps (keeping only last $retention dump files)""
purge "dump_${database}_*.gz" $retention $dump_dir

exit 0
