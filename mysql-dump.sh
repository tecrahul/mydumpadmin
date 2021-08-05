#!/usr/bin/env bash

####################################################################################
####################################################################################
###
####       Author: Rahul Kumar
#####      Email: rahul@tecadmin.net
#####      Website: https://tecadmin.net
####       Version 4.0
###
####################################################################################
####################################################################################

CONFIGFILE=/etc/mydumpadmin/settings.conf

source $CONFIGFILE
DATE_FORMAT='%Y%m%d'
CURRENT_DATE=$(date +"${DATE_FORMAT}")
CURRENT_TIME=$(date +"%H%M")
LOGFILENAME=$LOG_PATH/mydumpadmin-${CURRENT_DATE}-${CURRENT_TIME}.log
CREDENTIALS="--defaults-file=$CREDENTIAL_FILE"


[ ! -d $LOG_PATH ] && ${MKDIR} -p ${LOG_PATH}
echo "" > ${LOGFILENAME}
echo "<<<<<<   Database Dump Report :: `date +%D`  >>>>>>" >> ${LOGFILENAME}
echo "" >> ${LOGFILENAME}
echo "DB Name  :: DB Size   Filename" >> ${LOGFILENAME}

### Make a backup ###
check_config(){
	### Check if configuration file exists.
        [ ! -f $CONFIGFILE ] && close_on_error "Config file not found, make sure config file is correct"
}
db_backup(){

	### Start database backups
        if [ "$DB_NAMES" == "ALL" ]; then
		DATABASES=`$MYSQL $CREDENTIALS -h $MYSQL_HOST -P $MYSQL_PORT -Bse 'show databases' | grep -Ev "^(Database|mysql|performance_schema|information_schema)"$`
        else
		DATABASES=$DB_NAMES
        fi

        db=""
        [ ! -d $BACKUPDIR ] && ${MKDIR} -p $BACKUPDIR
                [ $VERBOSE -eq 1 ] && echo "*** Dumping MySQL Database ***"
                mkdir -p ${LOCAL_BACKUP_DIR}/${CURRENT_DATE}
        for db in $DATABASES
        do
                FILE_NAME="${db}.${CURRENT_DATE}-${CURRENT_TIME}.sql.gz"
                FILE_PATH="${LOCAL_BACKUP_DIR}/${CURRENT_DATE}/"
                FILENAMEPATH="$FILE_PATH$FILE_NAME"
                [ $VERBOSE -eq 1 ] && echo -en "Database> $db... \n"
                ${MYSQLDUMP} ${CREDENTIALS} --single-transaction -h ${MYSQL_HOST} -P $MYSQL_PORT $db | ${GZIP} -9 > $FILENAMEPATH
                echo "$db   :: `du -sh ${FILENAMEPATH}`"  >> ${LOGFILENAME}
                [ $FTP_ENABLE -eq 1 ] && ftp_backup
                [ $SFTP_ENABLE -eq 1 ] && sftp_backup
                [ $S3_ENABLE -eq 1 ] && s3_backup
        done
        [ $VERBOSE -eq 1 ] && echo "*** Backup completed ***"
        [ $VERBOSE -eq 1 ] && echo "*** Check backup files in ${FILE_PATH} ***"
}

### close_on_error on demand with message ###
close_on_error(){
        echo "$@"
        exit 99
}

### Make sure bins exists.. else close_on_error
check_cmds(){
        [ ! -x $GZIP ] && close_on_error "FILENAME $GZIP does not exists. Make sure correct path is set in $CONFIGFILE."
        [ ! -x $MYSQL ] && close_on_error "FILENAME $MYSQL does not exists. Make sure correct path is set in $CONFIGFILE."
        [ ! -x $MYSQLDUMP ] && close_on_error "FILENAME $MYSQLDUMP does not exists. Make sure correct path is set in $CONFIGFILE."
        [ ! -x $RM ] && close_on_error "FILENAME $RM does not exists. Make sure correct path is set in $CONFIGFILE."
        [ ! -x $MKDIR ] && close_on_error "FILENAME $MKDIR does not exists. Make sure correct path is set in $CONFIGFILE."
        [ ! -x $MYSQLADMIN ] && close_on_error "FILENAME $MYSQLADMIN does not exists. Make sure correct path is set in $CONFIGFILE."
        [ ! -x $GREP ] && close_on_error "FILENAME $GREP does not exists. Make sure correct path is set in $CONFIGFILE."
	if [ $S3_ENABLE -eq 1 ]; then
	       [ ! -x $S3CMD ] && close_on_error "FILENAME $S3CMD does not exists. Make sure correct path is set in $CONFIGFILE."
	fi
	if [ $SFTP_ENABLE -eq 1 ]; then
		[ ! -x $SCP ] && close_on_error "FILENAME $SCP does not exists. Make sure correct path is set in $CONFIGFILE."
	fi
}

### Check if database connectin is working...
check_mysql_connection(){
        ${MYSQLADMIN} ${CREDENTIALS} -h ${MYSQL_HOST} -P ${MYSQL_PORT} ping | ${GREP} 'alive'>/dev/null
        [ $? -eq 0 ] || close_on_error "Error: Cannot connect to MySQL Server. Make sure username and password setup correctly in $CONFIGFILE"
}



### Copy backup files to ftp server
ftp_backup(){
[ $VERBOSE -eq 1 ] && echo "Uploading backup file to FTP"
ftp -n $FTP_SERVER << EndFTP
user "$FTP_USERNAME" "$FTP_PASSWORD"
binary
hash
cd $FTP_UPLOAD_DIR
lcd $FILE_PATH
put "$FILE_NAME"
bye
EndFTP
}

### Copy backup files to sftp server
sftp_backup(){

	[ $VERBOSE -eq 1 ] && echo "Uploading backup file to SFTP"
	cd ${FILE_PATH}
	${SCP} -P ${SFTP_PORT}  "$FILE_NAME" ${SFTP_USERNAME}@${SFTP_HOST}:${SFTP_UPLOAD_DIR}/

}

### Copy backup files to Amazon S3 bucket
s3_backup(){
	[ $VERBOSE -eq 1 ] && echo "Uploading backup file to S3 Bucket"
	cd ${FILE_PATH}
	$S3CMD --access_key="$AWS_ACCESS_KEY" --secret_key="$AWS_SECRET_ACCESS_KEY" put "$FILE_NAME" s3://${S3_BUCKET_NAME}/${S3_UPLOAD_LOCATION}/
}

### Remove older backups
clean_old_backups(){

	[ $VERBOSE -eq 1 ] && echo "Removing old backups"
	DBDELDATE=`date +"${DATE_FORMAT}" --date="${BACKUP_RETAIN_DAYS} days ago"`
	if [ ! -z ${LOCAL_BACKUP_DIR} ]; then
		  cd ${LOCAL_BACKUP_DIR}
		  if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
				rm -rf ${DBDELDATE}
		  fi
	fi
}

### Send report email
send_report(){
	if [ $SENDEMAIL -eq 1 ]
	then
			cat ${LOGFILENAME} | mail -vs "Database dump report for `date +%D`" ${EMAILTO}
	fi
}



### main ####
check_config
check_cmds
check_mysql_connection
db_backup
clean_old_backups
send_report
