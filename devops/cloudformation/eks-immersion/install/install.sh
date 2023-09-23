#!/bin/bash

FAILED_SCRIPT=''
trap cleanup ERR

function cleanup() {
 if [ ! -z "$FAILED_SCRIPT" ] ; then
 source ./cleanup.sh
 cleanup_$FAILED_SCRIPT
 fi
}

source ./init.sh >> /tmp/scriptLogs.txt

grep 'increase-disk-size.sh' /tmp/lastExecutedScript.txt
CMDEXEC=$?
if [ $CMDEXEC -ne 0 ]; then
FAILED_SCRIPT='increase-disk-size.sh'
set -ex
source ./increase-disk-size.sh >> /tmp/scriptLogs.txt
set +ex
fi
echo `date` 'increase-disk-size.sh' >> /tmp/lastExecutedScript.txt
FAILED_SCRIPT=''

grep 'eks-tool-set.sh' /tmp/lastExecutedScript.txt
CMDEXEC=$?
if [ $CMDEXEC -ne 0 ]; then
FAILED_SCRIPT='eks-tool-set.sh'
set -ex
source ./eks-tool-set.sh >> /tmp/scriptLogs.txt
set +ex
fi
echo `date` 'eks-tool-set.sh' >> /tmp/lastExecutedScript.txt
FAILED_SCRIPT=''

grep 'eks-cluster.sh' /tmp/lastExecutedScript.txt
CMDEXEC=$?
if [ $CMDEXEC -ne 0 ]; then
FAILED_SCRIPT='eks-cluster.sh'
set -ex
source ./eks-cluster.sh >> /tmp/scriptLogs.txt
set +ex
fi
echo `date` 'eks-cluster.sh' >> /tmp/lastExecutedScript.txt
FAILED_SCRIPT=''
