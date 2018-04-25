fetch_vbmc ()
{
    if ! locate site-packages | grep "virtualbmc/" &> /dev/null
    then
        try "$PKG_CUST" install python-setuptools libvirt-devel python-devel || failure
        try easy_install pip || failure
        try pip install virtualbmc || failure
    fi
}
