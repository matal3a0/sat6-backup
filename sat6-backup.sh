#!/bin/bash

BACKUPDIR="/backup"                   # Path to store backups
BACKUPBIN="/usr/bin/foreman-maintain" # Path to foreman-maintain
KEEP=14                               # Number of days to keep old backups
LOGDIR="/var/log"                     # Path to store log

LOGFILE="$LOGDIR/sat6-backup.log"     
SCRIPTDIR=$(dirname "$0")
SCRIPTDIR=$(cd "$SCRIPTDIR" && pwd)

MODE=$1

date "+%F %T" | tee -a $LOGFILE

# Check mountpoint
if ! grep -qs $BACKUPDIR /proc/mounts; then
    echo "Backup directory $BACKUPDIR not mounted!" | tee -a $LOGFILE
    echo "------------------------------------------" | tee -a $LOGFILE
    exit 1
fi

case "$MODE" in
    full)
        # Full backup
        echo "Running full backup" | tee -a $LOGFILE
        $BACKUPBIN backup offline --assumeyes --skip-pulp-content $BACKUPDIR/full 
        date "+%F %T" | tee -a $LOGFILE
        echo "Backup full Finished" | tee -a $LOGFILE
        ;;

    inc)
        # Incremental
        echo "Running incremental backup" | tee -a $LOGFILE
        LASTBACKUPDIR=$(ls -d $BACKUPDIR/full/* | tail -n 1)
        echo "Last backupdir: $LASTBACKUPDIR"
        if [ -z "$LASTBACKUPDIR" ]; then
            echo "Couldn't find last backup dir, aborting!" | tee -a $LOGFILE
            exit 2
        else
            $BACKUPBIN backup offline --skip-pulp-content --assumeyes --incremental "$LASTBACKUPDIR" $BACKUPDIR/inc 
            date "+%F %T" | tee -a $LOGFILE
            echo "Backup Incremental Finished" | tee -a $LOGFILE
        fi
        ;;
    clean)
        # Clean out old backups
        echo "Cleaning old backups" | tee -a $LOGFILE
        find $BACKUPDIR -name "satellite-backup-*" -mtime +$KEEP -print -prune -exec rm -rf {} \; 2>&1 | tee -a $LOGFILE
        ;;
    *)
        echo "Usage: $0 {full|inc|clean}"
        exit 1
esac

date "+%F %T" | tee -a $LOGFILE
echo "Exit script of backup" | tee -a $LOGFILE
echo "------------------------------------------" | tee -a $LOGFILE
exit 0
