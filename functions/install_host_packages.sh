install_host_packages ()
{
    echo "Adding needed/wanted packages to the host."
    try yum -q install -y elinks facter libguestfs-tools-c libguestfs-xfs libvirt mc mlocate qemu-kvm tree vim virt-install virt-manager xauth xorg-x11-apps xorg-x11-fonts-Type1 &> /dev/null || failure
    try yum -q group install -y "Development Tools" &> /dev/null || failure
}
