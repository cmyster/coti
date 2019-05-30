fetch_vbmc ()
{
    install_deps ()
    {
        for pkg in "python3-setuptools" "libvirt-devel" "python3-devel"
        do
            if ! rpm -qa | grep $pkg &> /dev/null
            then
                try "$PKG_CUST" install $pkg || failure
            fi
        done
    }

    install_pip ()
    {
        if [ ! -d /usr/local/lib/python3.6/site-packages ]
        then
            mkdir -p /usr/local/lib/python3.6/site-packages
        fi
        if ! which pip &> /dev/null
        then
            install_deps
            try easy_install-3 -q pip &> /dev/null || failure
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
