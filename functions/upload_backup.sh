upload_backup ()
{
    NODE_NAME=$1
    echo "Uploading backup file from old Undercloud to new Undercloud."
    try virt-customize -m 4096 --smp 4 -q -a $VIRT_IMG/${NODE_NAME}.raw --upload $WORK_DIR/undercloud-backup.tar:/root || failure
}
