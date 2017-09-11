fetch_vbmc ()
{
    if ! rpm -qa | grep virtualbmc &> /dev/null
    then
        try yum install python-setuptools libvirt-devel python-devel || failure
        try easy_install pip || failure
        try pip install virtualbmc || failure
    fi
}
