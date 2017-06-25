install_host_packages ()
{
    echo "Adding needed/wanted packages to the host."
    PACKS1="python-pyghmi python-pbr python-prettytable"
    PACKS2="elinks facter mc mlocate tree vim"
    PACKS3="xorg-x11-apps xorg-x11-fonts-Type1 xauth"
    PACKS4="libvirt qemu-kvm virt-manager virt-install libguestfs-xfs libguestfs-tools-c"
    try yum -q install -y $PACKS1 $PACKS2 $PACKS3 $PACKS4  &> /dev/null || failure
    try yum -q group install -y "Development Tools" &> /dev/null || failure
}
