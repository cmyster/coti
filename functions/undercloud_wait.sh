undercloud_wait ()
{
    echo "Waiting for the undercloud machine to contact."
    # I expect that the name is defined at NODES[0]. The first of those is
    # something like undercloud-0
    NODE_NAME="$1"
    for i in $(seq 1 100)
    do
        case $i in
            100)
                raise "${FUNCNAME[0]}"
                ;;
        esac

        if [ -r "${NODE_NAME}".hello ]
        then
            source "${NODE_NAME}".hello
            if [ -z "$IP" ] || [ -z "$HOST" ]
            then
                echo "An undercloud called $HOST sent a bad hello file."
                raise "${FUNCNAME[0]}"
            else
                echo "An undercloud called $HOST sent hello from ${IP}."
                echo "Writing $HOST ($IP) to /etc/hosts"
                sed -i '/'"$HOST"'/d' /etc/hosts
                echo "$IP $HOST" >> /etc/hosts
            fi
            break
        fi
        sleep 10
    done
}
