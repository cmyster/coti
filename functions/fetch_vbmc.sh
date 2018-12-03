fetch_vbmc ()
{
    # Dependencies
    try "$PKG_CUST" install python-setuptools libvirt-devel python-devel || failure

    # Install PIP.
    if ! which pip &> /dev/null
    then
        try easy_install pip || failure
    fi

    # Install VirtualBMC.
    if ! locate site-packages | grep "virtualbmc/" &> /dev/null
    then
        try pip install virtualbmc || failure
    fi
}
