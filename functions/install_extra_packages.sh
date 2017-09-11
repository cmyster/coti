install_extra_packages ()
{
    download_from_epel ()
    {
        echo "Downloading $1"
        try wget -q -nv -r -nd -np ${EPEL}/${1:0:1}/ -A "${1}*rpm" || failure
        if ! rpm -qa | grep $1 &> /dev/null
        then
            echo "Installing $1"
            yum install $1 -y -q
        fi
    }

    try wget -q -nv $LATEST_RR || failure
    try wget -q -nv $RHEL_GUEST || failure
    
    for package in "python-psutil" "nethogs" "htop" "glances" "sshpass"
    do
        download_from_epel $package
    done

    echo "Tarring needed files."
    tar cf files.tar *.rpm *.conf &> /dev/null
}
