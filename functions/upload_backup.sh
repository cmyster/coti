upload_backup ()
{
    NODE_NAME=$1
    echo "Uploading backup file from old Undercloud to new Undercloud."
    try virt-customize $CUST_ARGS -a $VIRT_IMG/${NODE_NAME}.raw --upload $WORK_DIR/undercloud-backup.tar:/root || failure
}
