upload_backup ()
{
    UNDER_NODE_NAME=$1
    echo "Uploading backup file from old Undercloud to new Undercloud."
    try virt-customize -q -a $VIRT_IMG/${UNDER_NODE_NAME}.raw --upload $WORK_DIR/undercloud-backup.tar:/root || failure
}
