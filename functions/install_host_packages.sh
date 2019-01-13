install_host_packages ()
{
    echo "Adding needed/wanted packages to the host."
    PACKS1="python-pyghmi python-pbr python-prettytable yum-utils"
    PACKS2="elinks facter mc mlocate tree vim wireshark-gnome"
    PACKS3="xorg-x11-apps xorg-x11-fonts-Type1 xauth"
    PACKS4="libvirt qemu-kvm virt-manager virt-install libguestfs-xfs libguestfs-tools-c"
    try "$PKG_CUST" install "$PACKS1 $PACKS2 $PACKS3 $PACKS4"  &> /dev/null || failure
    try "$PKG_CUST" group install "Development Tools" &> /dev/null || failure
}
