#!/bin/bash

echo "starting transfer to AWS EFS mount at " $(date)
(cd /var/www/html && tar c .) | (cd /mnt/efs/fs1 && tar xf -) & pid=$!
# or
#rsync -a /var/www/html/ /mnt/efs/fs1/html/ & pid=$!
wait $pid
echo $pid completed.
echo "ending copy to AWS EFS mount at " $(date)
chown -R ubuntu:www /mnt/efs/fs1
echo "Job done!"
