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

### Backing up the Database to AWS S3 Bucket

The code uses s3cmd tool available at https://github.com/s3tools/s3cmd

To backup to AWS S3 bucket, you are required to install the s3cmd tool on your server, else the backup process will fail. Installation instruction for s3cmd tool is available at https://github.com/s3tools/s3cmd/blob/master/INSTALL.md

After installation, you are required to update the **settigns.conf** file with the path to the installed s2cmd tool. You can achieve this by updating the **S3CMD** variable in **settings.conf**. The default path for installation of s3cmd on Ubuntu/Debian servers is **/usr/local/bin/s3cmd**

It is also advised to run 

> s3cmd --configure

The above command sets the AWS access_key and secret_key so that it can be omitted from your code for security reasons. If you run the configure command, your s3 backup script from **mysql-dump.sh** can become

> $S3CMD put "$FILE_NAME" s3://${S3_BUCKET_NAME}/${S3_UPLOAD_LOCATION}/

instead of 

> $S3CMD --access_key="$AWS_ACCESS_KEY" --secret_key="$AWS_SECRET_ACCESS_KEY" put "$FILE_NAME" s3://${S3_BUCKET_NAME}/${S3_UPLOAD_LOCATION}/


### Visit here

- [TecAdmin: MySQL Database Backup Script](https://tecadmin.net/bash-script-mysql-database-backup/)
- [TecAdmin: Advanced Bash Script for MySQL Database Backup](https://tecadmin.net/advance-bash-script-for-mysql-database-backup/)
