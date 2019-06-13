get_undercloud_image ()
{
    MODIFIED_GUEST_PATH="$(cat modified_guest)"

    PUDDLE=$(cat puddle)
    echo "Dowloading guest image."
    try wget -N -q -nv $MODIFIED_GUEST || failure
    try qemu-img convert -f qcow2 -O raw $MODIFIED_GUEST guest-image.raw || failure
    rm -rf guest-image.qcow2
}
