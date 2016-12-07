restart_libvirt ()
{
    echo "restarting libvirtd service"
    try systemctl stop libvirtd &> /dev/null || failure
    try systemctl start libvirtd &> /dev/null || failure
}
