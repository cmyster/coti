proto_prerun ()
{
    echo "Changing root password to ${ROOT_PASS}"
    try virt-customize "$VIRSH_CUST" -a "$VIRT_IMG"/proto.qcow2 --selinux-relabel --root-password password:"${ROOT_PASS}" || failure
    echo "Uploading files.tar to /root"
    try virt-customize "$VIRSH_CUST" -a "$VIRT_IMG"/proto.qcow2 --upload "$WORK_DIR"/files.tar:/root || failure
}
