#!/bin/bash

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
#      Create nfs server share and mount it on each node
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

# TODO: Move all this script to ansible role

NOW=$(date +"%d-%m-%Y")
echo "[$NOW] batch started"

# On nfs server
mkdir /mnt/nfs && chmod -R /mnt/nfs
echo "/mnt/nfs        *(rw,sync,root_squash,fsid=0,no_subtree_check)" >> /etc/exports
/etc/init.d/nfs-kernel-server reload

# For all others nodes
set -e
[ -d /mnt/nfs ] || mkdir /mnt/nfs
chmod 777 -R /mnt/nfs;
echo "151.80.235.155:/mnt/nfs /mnt/nfs nfs rw,nosuid 0 0" >> /etc/fstab && mount -a;
ls /mnt/nfs

# Freebox volume share 

sudo apt-get install curlftpfs
echo "curlftpfs#freebox:Fezzeni82@heni.freeboxos.fr:58002/  /mnt/nfs/freebox    fuse  ssl_control,ssl,user=freebox:Fezzeni82,uid=1000,gid=1000,umask=003,no_verify_peer,utf8,no_verify_hostname 0 0" >> /etc/fstab
mount -a 

NOW=$(date +"%d-%m-%Y")
echo "[$NOW] batch finished"

exit 0