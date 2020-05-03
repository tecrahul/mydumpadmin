## Advance MySQL Database Backup Script

In this repository, you will get an advance MySQL database backup script with mutiple options. This script allows you to backup databases on local and upload to FTP, SFTP and S3 bucket. 

### Clone this repository

Clone this repository under **/etc** directory.

> cd /etc/

> git clone https://github.com/tecrahul/mydumpadmin


### Configure setup

Edit **settings.conf** file and update all requied values as per your requirements. You can enable/disable FTP, SFTP backups here.

Now edit **credentials.txt** file and put your mysql server login details




### Execute backup script

Run the following commands step by step to execute this script.

> cd /etc/mydumpadmin

> chmod a+x mysql-dump.sh

> ./mysql-dump.sh


### Schedule daily cron

You can also schedule this to run on daily basis using crontab. Add the following settings to crontab to run on 2:00 AM daily.

> 0 2 * * * cd /etc/mydumpadmin && ./mysql-dump.sh


### Visit here
https://tecadmin.net/bash-script-mysql-database-backup/

https://tecadmin.net/advance-bash-script-for-mysql-database-backup/
