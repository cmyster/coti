install_host_packages ()
{
    echo "Adding needed | wanted packages to the host."
    try yum install -y elinks facter libguestfs-tools-c libguestfs-xfs libvirt mc openvswitch qemu-kvm sshpass tree vim virt-install virt-manager xauth xorg-x11-apps xorg-x11-fonts-Type1 || failure
    try yum group install -y "Development Tools" || failure
}
