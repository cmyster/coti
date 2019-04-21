proto_clean ()
{
    try virt-sysprep -q -a "$VIRT_IMG"/proto.qcow2 --operations abrt-data,ssh-hostkeys,udev-persistent-net,net-hostname,net-hwaddr,logfiles,bash-history || failure
    virt-sparsify -q --compress "$VIRT_IMG"/proto.qcow2 "$(cat guest_image)"
}
