predefined_images ()
{
    LIBGUESTFS_BACKEND=direct

    # getting the premade director RPMs
    try wget -q $OC_IMAGES || failure
    try wget -q $OC_IPA || failure

    # extracting
    rpm2cpio $(basename $OC_IMAGES) | cpio -idmv
    rpm2cpio $(basename $OC_IPA) | cpio -idmv

    tar xf usr/share/rhosp-director-images/overcloud-full* -C .
    tar xf usr/share/rhosp-director-images/ironic-python-agent* -C .
}
