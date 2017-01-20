install_host_packages ()
{
    echo "Adding needed | wanted packages to the host."
    PACKAGES=( 
              facter
              libguestfs-tools-c
              libguestfs-xfs
              libvirt
              mc
              openstack-tripleo-common
              openvswitch
              qemu-kvm
              sshpass
              tree
              vim
              virt-install
              virt-manager virt-viewer
              xauth
              xorg-x11-apps
             )
    try yum install -y ${PACKAGES[@]} || failure
    try yum group install -y "Development Tools" || failure
}
