# sat6-backup
## Backup script for Red Hat Satellite 6

Satellite 6 includes katello-backup, which takes care of backing up all the configuration, databases and pulp repo-data.
But you still have to maintain the logic of the backups yourself, i.e. when to do full, incremental and purging old backups.
This script handles just that.
```
Usage:
	sat6-backup.sh {full|incr|clean}
```

### Cron-example:
```
00 00 * * SUN		/path/to/sat6-backup.sh full
00 00 * * MON-SAT	/path/to/sat6-backup.sh incr
01 00 * * *		/path/to/sat6-backup.sh clean
```
Runs one full backup every sunday. Incremental monday to saturday. Clean out old backups every day.
Age of backups to be deleted can be configured in the script.
