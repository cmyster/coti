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
            try easy_install pip || failure
        fi
    }

    install_vbmc ()
    {
        if ! locate site-packages | grep "virtualbmc/" &> /dev/null
        then
            install_pip
            try pip install virtualbmc || failure
        fi
    }

    #if ! pgrep -a vbmcd &> /dev/null
    #then
        install_vbmc
        #echo "Starting vbmcd."
        #try vbmcd || failure
        #vbmcd_pid=$(pgrep -a vbmcd | awk '{print $1}')
        #if ! ps -o pid= -p $vbmcd_pid &> /dev/null
        #then
        #    echo "Couldn't start vbmcd."
        #    raise "${FUNCNAME[0]}"
        #fi
    #fi
}
