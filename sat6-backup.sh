#!/bin/bash

SCRIPTDIR=$(dirname "$0")
SCRIPTDIR=$(cd "$SCRIPTDIR" && pwd)
BACKUPDIR="/backup" 		# Path to store backups
BACKUPBIN="/bin/katello-backup" # Path to katello-backup
TODAY=$(date +%y%m%d)
YESTERDAY=$(date --date=yesterday +%y%m%d)
KEEP=7				# Number of days to keep old backups
LOGDIR="/var/log"		
LOGFILE="$LOGDIR/sat6-backup.log"
MODE=$1

date "+%F %T" | tee -a $LOGFILE 

# Check mountpoint
if ! grep -qs $BACKUPDIR /proc/mounts; then
	echo "Backup directory $BACKUPDIR not mounted!"
	exit 1
fi

case "$MODE" in
	full)
		# Full backup
		echo "Running full backup" | tee -a $LOGFILE
		$BACKUPBIN $BACKUPDIR/sat6-backup-$TODAY-full 2>&1 | tee -a $LOGFILE
		;;

	incr)
		# Incremental
		echo "Running incremental backup" | tee -a $LOGFILE
		LASTBACKUPDIR=$(ls -d $BACKUPDIR/sat6-backup* | tail -n 1)
		echo "Last backupdir: $LASTBACKUPDIR"
		if [ -z "$LASTBACKUPDIR" ]; then
			echo "Couldn't find last backup dir, aborting!" | tee -a $LOGFILE
			exit 2
		else
			$BACKUPBIN --incremental $LASTBACKUPDIR $BACKUPDIR/sat6-backup-$TODAY-incr 2>&1 | tee -a $LOGFILE
		fi
		;;
	clean)
		# Clean out old backups
		echo "Cleaning old backups" | tee -a $LOGFILE
		find $BACKUPDIR -maxdepth 1 -name "sat6-backup-*" -mtime +$KEEP -print0 | xargs -0 rm -rf 2>&1 | tee -a $LOGFILE
		;;
	*)
		echo "Usage: $0 {full|incr|clean}"
		exit 1
esac

date "+%F %T" | tee -a $LOGFILE

exit 0
