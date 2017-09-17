upload_backup ()
{
    HOST=$1
    echo "Uploading backup file from old Undercloud to new Undercloud."
    BACKUP_FILE=$(find $WORK_DIR -type f -name "*backup.tar")
    try virt-customize $VIRSH_CUST -a $VIRT_IMG/${HOST}.raw --upload ${BACKUP_FILE}:/root || failure
}
