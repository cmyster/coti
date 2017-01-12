restart_libvirt ()
{
    echo "Restarting libvirtd service."
    try systemctl stop libvirtd &> /dev/null || failure
    try systemctl start libvirtd &> /dev/null || failure
}
