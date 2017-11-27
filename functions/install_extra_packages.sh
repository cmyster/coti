install_extra_packages ()
{
    download_from_epel ()
    {
        set -x
        if ! /bin/ls ${1}*rpm &> /dev/null
        then
            echo "Downloading $1"
            try wget -q -nv -r -nd -np ${EPEL}/${1:0:1}/ -A "${1}*rpm" || failure
        fi
    }

    install_if_not ()
    {
        if ! rpm -qa | grep $1 &> /dev/null
        then
            echo "Installing $1"
            pkg=$(/bin/ls -1 ${1}*)
            rpm -Uvh $pkg
        fi
    }

    if ! /bin/ls rhos-release-latest.noarch.rpm
    then
        try wget -q -nv $LATEST_RR || failure
    fi

    if ! /bin/ls rhel-guest-image*
    then
        try wget -q -nv $RHEL_GUEST || failure
    fi
    
    for package in "nethogs" "htop" "sshpass"
    do
        download_from_epel $package
        install_if_not $package
    done

    echo "Tarring needed files."
    tar cf files.tar *.rpm *.conf &> /dev/null
}
