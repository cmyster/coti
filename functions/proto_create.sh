proto_create ()
{
    RHEL_GUEST=$(cat guest_image)
    if [ ! -d "$WORK_DIR/appliance" ]
    then
        get_appliance
    fi

    try qemu-img create -f qcow2 -o preallocation=full "$VIRT_IMG"/proto.qcow2 16G || failure
    try virt-resize -q --expand /dev/sda1 "$WORK_DIR"/"$(basename "$RHEL_GUEST")" "$VIRT_IMG"/proto.qcow2 || failure
    rm -rf "$WORK_DIR/$(basename "$RHEL_GUEST")"
}
