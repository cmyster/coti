install_host_minimal_packages ()
{
    echo "Adding needed | wanted packages to the host."
    try yum install -y elinks facter mc sshpass tree vim || failure
}
