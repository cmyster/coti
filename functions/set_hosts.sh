set_hosts ()
{
    if [ -z "$1" ] || [ -z "$2" ]
    then
        raise ${FUNCNAME[0]}
    fi
    echo "writing $1 ($2) to /etc/hosts"
    sed -i '/'$1'/d' /etc/hosts
    echo "$2 $1" >> /etc/hosts
}

