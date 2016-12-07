proto_create ()
{
    try qemu-img create -f qcow2 $VIRT_IMG/proto.qcow2 13G || failure
    try virt-resize -q --expand /dev/sda1 $WORK_DIR/$(basename $RHEL_GUEST) $VIRT_IMG/proto.qcow2 || failure
    rm -rf $WORK_DIR/$(basename $RHEL_GUEST)
}
