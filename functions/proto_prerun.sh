proto_prerun ()
{
    echo "Making it possible to connect later as root via SSH."
    echo "Changing root password to ${ROOT_PASS}"
    echo "Uploading files.tar to /root"
    virt-customize $VIRSH_CUST -a "$VIRT_IMG"/proto.qcow2 \
        --run-command "rpm -e cloud-init" \
        --run-command "sed 's|SELINUX=.*|SELINUX=disabled|g' -i /etc/selinux/config" \
        --run-command "chmod 0660 /etc/ssh/sshd_config" \
        --run-command "sed 's|PasswordAuthentication.*|PasswordAuthentication yes|g' -i /etc/ssh/sshd_config" \
        --selinux-relabel --root-password password:"${ROOT_PASS}" \
        --upload "$WORK_DIR"/files.tar:/root
}
