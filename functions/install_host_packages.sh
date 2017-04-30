install_host_packages ()
{
    echo "Adding needed | wanted packages to the host."
    try yum install -y libguestfs-tools-c libguestfs-xfs libvirt openstack-tripleo-common openvswitch qemu-kvm virt-install virt-manager xauth xorg-x11-apps || failure
    try yum group install -y "Development Tools" || failure
}
