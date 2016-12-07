get_undercloud_image ()
{
    echo "Dowloading guest image."
    try wget -N -q -nv $MODIFIED_GUEST || failure
    try qemu-img convert -f qcow2 -O raw guest-image.qcow2 guest-image.raw || failure
    rm -rf guest-image.qcow2
}
