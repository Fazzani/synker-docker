#!/bin/bash

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
#      Create nfs server share and mount it on each node
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

# TODO: Move all this script to ansible role

script=$(basename "$0")

function log {
   echo -e "[$(date +"%d-%m-%Y %H:%M:%S") $HOSTNAME $USER $script] $1" 
}

log "batch started"

# On nfs server
mkdir -p /mnt/nfs && chmod -R /mnt/nfs
echo "/mnt/nfs        *(rw,sync,root_squash,fsid=0,no_subtree_check)" >> /etc/exports
/etc/init.d/nfs-kernel-server reload

# For all others nodes
set -e
[ -d /mnt/nfs ] || -p mkdir /mnt/nfs
chmod 777 -R /mnt/nfs;
echo "151.80.235.155:/mnt/nfs /mnt/nfs nfs rw,nosuid 0 0" >> /etc/fstab && mount -a;
ls /mnt/nfs

# Freebox volume share 

sudo mkdir -p /mnt/freebox && sudo chmod 777 /mnt/freebox
sudo apt-get install curlftpfs
echo "curlftpfs#freebox:Fezzeni82@heni.freeboxos.fr:58002/  /mnt/freebox/test/    fuse  rw,ssl_control,ssl,allow_other,uid=1000,_netdev 0 0" | sudo tee /etc/fstab > /dev/null
mount -av

log "batch finished"

exit 0