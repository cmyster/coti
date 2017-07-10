fetch_vbmc ()
{
    if ! rpm -qa | grep virtualbmc &> /dev/null
    then
        try pip install virtualbmc || failure
    fi
}
