proto_create ()
{
    if [ -r guest_image ]
    then
        RHEL_GUEST=$(cat guest_image)
    else
        raise "${FUNCNAME[0]}"
    fi
    try qemu-img create -f qcow2 -o preallocation=full "$VIRT_IMG"/proto.qcow2 8G || failure
    try virt-resize -q --expand /dev/sda1 "$WORK_DIR"/"$(basename "$RHEL_GUEST")" "$VIRT_IMG"/proto.qcow2 || failure
    rm -rf "$WORK_DIR/$(basename "$RHEL_GUEST")"
}
