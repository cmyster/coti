undercloud_wait ()
{
    echo "waiting for the undercloud machine to contact"
    # I expect that the name is defined at NODES[0]. The first of those is
    # something like undercloud-0
    UNDER_NODE_NAME="$1"
    for i in $(seq 1 100)
    do
        case $i in
            100)
                raise ${FUNCNAME[0]}
                ;;
        esac

        if [ -r ${UNDER_NODE_NAME}.hello ]
        then
            source ${UNDER_NODE_NAME}.hello
            if [ -z "$IP" ] || [ -z "$HOST" ]
            then
                echo "an undercloud called $HOST sent an empty hello"
                raise ${FUNCNAME[0]}
            else
                echo "an undercloud called $HOST sent hello from $IP"
                try set_hosts $HOST $IP || failure
            fi
            break
        fi
        sleep 10
    done
}
