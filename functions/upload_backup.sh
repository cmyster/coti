upload_backup ()
{
    HOST=$1
    echo "Uploading backup file from old Undercloud to new Undercloud."
    BACKUP_FILE=$(find $WORK_DIR -type f -name "*backup.tar")
    try virt-customize $CUST_ARGS -a $VIRT_IMG/${HOST}.raw --upload ${WORK_DIR}/${BACKUP_FILE}:/root || failure
}
