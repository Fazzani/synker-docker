#!/usr/bin/env bash

#-------------------------------------
#
# Dumping Postgresql database
# with max retention of dump files
#
#-------------------------------------
# Provide a variable with the location of this script.
scriptPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

utilsLocation="${scriptPath}/lib/utils.sh" # Update this path to find the utilities.

if [ -f "${utilsLocation}" ]; then
  source "${utilsLocation}"
fi

set +e
#set -x

db_container_id=$(sudo docker ps -q -f "name=synker_synkerdb")
####################################### script inputs
db_user=${1:-pl}
database=${2:-playlist}
retention=${3:-5}
####################################### functions

function purge() {
    local files_pattern_to_delete=${1:-'*.gz'}
    #retention days
    local r=${2:-3}
    # working directory
    local w_dir=${3:-'.'}

    files_count_to_delete="$(($(find $w_dir -name $files_pattern_to_delete -type f | wc -l) - $r))"
    rm -rf $(find $w_dir -name $files_pattern_to_delete -type f | sort -n | head -n $files_count_to_delete)
    # return 0
}

function restore(){
   local database=$1
   local dump_filename=$2
   local create_db_cmd=$(echo "psql -U postgres -tc \"SELECT 1 FROM pg_database WHERE datname = '$database'\" | grep -q 1 || psql -U postgres -c \"CREATE DATABASE $database\"")
    sudo docker exec -i $db_container_id \
     /bin/bash -c "$create_db_cmd && pg_restore -COc -n public -U $db_user -d $database /var/lib/postgresql/data/${dump_filename}"
}

function drop(){
  local database=$1
    sudo docker exec -i $db_container_id \
     /bin/bash -c "psql -U postgres -c DROP IF EXISTS DATABASE $database"
}
###################################### Variables

dump_dir="/mnt/nfs/postgres/data/"
dump_filename="dump_${database}_$(date +%F).tar.gz"
local_dump_file_path="${dump_dir}${dump_filename}"

##################################### script body
info "Database container Id : $db_container_id"
info "Dumping database: $database"
sudo docker exec -i $db_container_id \
     /bin/bash -c "pg_dump -n public -F t -U $db_user -f /var/lib/postgresql/data/${dump_filename} $database"

info "local_dump_file_path => $local_dump_file_path"

[ -f $local_dump_file_path ] && success "$database was dumped successfully" || { warning "Dump file missed"; exit -1; }

# info "Compressing dump"
gzip -9 -f $local_dump_file_path

info "Purging dumps (keeping only last $retention dump files)"
purge "dump_${database}_*.tar.gz" $retention $dump_dir

#info "Restoring database"
#restore playlistdev < gunzip  | $local_dump_file_path

exit 0