#!/usr/bin/env bash

#-------------------------------------
#
# Dumping Postgresql database
# with max retention of dump files
#
#-------------------------------------

# Provide a variable with the location of this script
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
database=${2:-playlist_dev}
retention=${3:-5}
###################################### Variables

dump_dir="/mnt/nfs/postgres/data/"
dump_filename="dump_${database}_$(date +%F).tar"
local_dump_file_path="${dump_dir}${dump_filename}"
local_dump_file_path_gz="${dump_dir}${dump_filename}.gz"
####################################### functions

function onexit() {
    info "Exiting"
    [ -f $local_dump_file_path ] && rm $local_dump_file_path
}

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

function restore() {
    local database=$1
    local dump_filename=$2

    info "Creating $database if not exist"
    sudo docker exec -i $db_container_id \
        /bin/bash -c "psql -U postgres -tc 'SELECT 1 FROM pg_database WHERE datname = $database' | grep -q 1 || createdb -U $db_user \"$database\""

    info "Restoring $database"
    sudo docker exec -i $db_container_id \
        /bin/bash -c "pg_restore -COc -n public -U $db_user -d $database /var/lib/postgresql/data/${dump_filename};"
}

function drop() {
    local database=$1
    local db_user=${2:-pl}

    info "Droping database $database"
    sudo docker exec -i $db_container_id \
        /bin/bash -c "dropdb --if-exists -U $db_user \"$database\""
    # /bin/bash -c "psql -U $db_user -c 'DROP DATABASE IF EXISTS \"$database\";'"
}

##################################### script body

trap onexit EXIT INT TERM

info "Database container Id : $db_container_id"
info "Backuping database: $database"
sudo docker exec -i $db_container_id \
    /bin/bash -c "pg_dump -n public -F t -U $db_user -f /var/lib/postgresql/data/${dump_filename} $database"

info "local_dump_file_path => $local_dump_file_path"

[ -f $local_dump_file_path ] && success "$database was backuped successfully" || {
    warning "Missed backup file"
    exit -1
}

info "Compressing backup"
gzip -9 -f $local_dump_file_path >$local_dump_file_path_gz

info "Purging backups (keeping only last $retention dump files)"
#purge "dump_${database}_*.tar.gz" $retention $dump_dir

# info "Restoring database"
# gunzip -c $local_dump_file_path_gz >$local_dump_file_path && \
#     drop playlist_tes pl && \
#     restore playlist_tes $dump_filename

exit 0
