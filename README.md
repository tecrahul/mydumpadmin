## Advance MySQL Database Backup Script

In this repository, you will get an advance MySQL database backup script with multiple options. This script allows you to backup databases locally and upload them to FTP, SFTP, and S3-compatible storage.

### Clone this repository

Clone this repository under **/etc** directory.

```bash
cd /etc/
git clone https://github.com/tecrahul/mydumpadmin
```

### Configure setup

Edit **settings.conf** file and update all required values as per your requirements. You can enable/disable FTP, SFTP, and S3 backups here.

For S3-compatible storage, ensure you add the **S3_ENDPOINT** variable in `settings.conf`, specifying your custom endpoint.

Now edit **credentials.txt** file and put your MySQL server login details.

### Install s3cmd for S3-compatible storage upload

To upload backups to an S3-compatible storage service, install `s3cmd` on your system:

- **Debian/Ubuntu**:

  ```bash
  sudo apt update && sudo apt install s3cmd -y
  ```

- **RHEL/CentOS**:

  ```bash
  sudo yum install s3cmd -y
  ```

- **MacOS (via Homebrew)**:

  ```bash
  brew install s3cmd
  ```

### Execute backup script

Run the following commands step by step to execute this script.

```bash
cd /etc/mydumpadmin
chmod a+x mysql-dump.sh
./mysql-dump.sh
```

### Schedule daily cron

You can also schedule this to run on a daily basis using crontab. Add the following settings to crontab to run at 2:00 AM daily.

```bash
0 2 * * * cd /etc/mydumpadmin && ./mysql-dump.sh
```

### Visit here

- [TecAdmin: MySQL Database Backup Script](https://tecadmin.net/bash-script-mysql-database-backup/)
- [TecAdmin: Advanced Bash Script for MySQL Database Backup](https://tecadmin.net/advance-bash-script-for-mysql-database-backup/)
