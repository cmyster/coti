fetch_vbmc ()
{
    install_deps ()
    {
        for pkg in "python-setuptools" "libvirt-devel" "python-devel"
        do
            if ! rpm -qa | grep $pkg &> /dev/null
            then
                try "$PKG_CUST" install $pkg || failure
            fi
        done
    }

    install_pip ()
    {
        if ! which pip &> /dev/null
        then
            install_deps
            try easy_install -q pip &> /dev/null || failure
        fi
    }

    install_vbmc ()
    {
        if ! locate site-packages | grep "virtualbmc/" &> /dev/null
        then
            install_pip
            try pip -q install virtualbmc || failure
        fi
    }

    install_vbmc
}
