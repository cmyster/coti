upload_backup ()
{
    HOST=$1
    echo "Uploading backup file from old Undercloud to new Undercloud."
    try virt-customize $CUST_ARGS -a $VIRT_IMG/${HOST}.raw --upload $WORK_DIR/undercloud-backup.tar:/root || failure
}
