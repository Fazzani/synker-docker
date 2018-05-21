#!/bin/bash

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
#      Create rsync (backup) cron for swarm cluster
#      rsync must be install on dest and src hosts
#      To execute on rasp1
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

NOW=$(date +"%d-%m-%Y")
echo "[$NOW] rsync batch started"

dest="/home/pi/toshiba/backup/swarm";
src_host="ansible@ovh1";
src_host_alias="151.80.235.155 ovh1";
cron="0 6 * * 0,3";

exclude_swarm_terms_array=('*.bak' '*.log' '/mnt/nfs/freebox' '/mnt/nfs/webgrab')
exclude_swarm_terms=$(printf "%s\n" "${exclude_swarm_terms_array[@]}")

[ -d $dest ] || mkdir -p ${dest}
(src_host_alias="151.80.235.155 ovh1"; cat /etc/hosts | grep -v -F "${src_host_alias}"; echo "${src_host_alias}") | sudo tee /etc/hosts > /dev/null
ssh-copy-id "${src_host}"
echo -e "${exclude_swarm_terms}" > "${dest}/exclude_swarm.txt"

croncmd="rsync -avz -e ssh --stats --progress --exclude-from="${dest}/exclude_swarm.txt" "${src_host}:/mnt/nfs" ${dest} > /log/rsync_swarm.log 2>&1"
cronjob="${cron} ${croncmd}"
( crontab -l | grep -v -F "$croncmd" ; echo -e "#rsync swarm \n${cronjob}" ) | crontab -

NOW=$(date +"%d-%m-%Y")
echo "[$NOW] rsync batch finished"

exit 0