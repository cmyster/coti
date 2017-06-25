fetch_vbmc ()
{
    if ! rpm -qa | grep python-virtualbmc &> /dev/null
    then
        HOST=$1
        $SSH $HOST "mkdir /root/vbmc"
        $SSH $HOST "yum -q install --downloadonly --downloaddir /root/vbmc/ python-virtualbmc"
        try scp -q $HOST:/root/vbmc/python-virtualbmc* . || failure
        try rpm -Uvh python-virtualbmc* || failure
    fi
}
