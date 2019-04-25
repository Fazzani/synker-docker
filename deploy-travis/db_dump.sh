#!/bin/bash

#-------------------------------------
#
# Dumping Postgresql database
# with max retention of dump files
#
#-------------------------------------

set +e
####################################### script inputs
db_user=${1:-pl}
database=${2:-playlist}
retention=${3:-5}
####################################### functions

function purge() {
    files_pattern_to_delete=${1:-'*.gz'}
    #retention days
    r=${2:-3}
    # working directory
    w_dir=${3:-'.'}

    files_count_to_delete="$(($(find $w_dir -name $files_pattern_to_delete -type f | wc -l) - $r))"
    rm -rf $(find $w_dir -name $files_pattern_to_delete -type f | sort -n | head -n $files_count_to_delete)
    # return 0
}
###################################### Variables

dump_dir="/mnt/nfs/postgres/data/"
dump_filename="dump_${database}_$(date +%F).sql"
local_dump_file_path="${dump_dir}${dump_filename}"

##################################### script body

sudo docker exec -i $(sudo docker ps -aq -f "name=synker_synkerdb") \
     /bin/bash -c "pg_dump -U $db_user $database > /var/lib/postgresql/data/${dump_filename}"

[ -f $local_dump_file_path ] || exit -1

# echo "Compressing dump"
gzip -f $local_dump_file_path

# echo "Purging dumps (keeping only last $retention dump files)"
purge "dump_${database}_*.gz" $retention $dump_dir

# exit 0