fetch_vbmc ()
{
    # Dependencies
    for pkg in "python-setuptools" "libvirt-devel" "python-devel"
    do
        if ! rpm -qa | grep $pkg &> /dev/null
        then
            try "$PKG_CUST" install $pkg || failure
        fi
    done

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

    if ! pgrep -a vbmcd &> /dev/null
    then
        echo "Starting vbmcd."
        try vbmcd || failure
    fi
}
