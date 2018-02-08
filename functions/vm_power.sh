vm_power ()
{
    HOST=$1
    OPTION=$2

    if [ -z "$HOST" ] || [ -z "$OPTION" ]
    then
        raise "${FUNCNAME[0]}"
    fi

    is_up ()
    {
        if virsh domstate "$HOST" | grep running 
        then
            return 0
        else
            return 1
        fi
    }

    stop ()
    {
        if is_up
        then
            online=true
            $SSH_CUST root@"$HOST" "shutdown -hP -t 0 now" &> /dev/null &
            while $online
            do
                if ! is_up
                then
                    online=false
                else
                    sleep 3
                fi
                echo "$HOST is offline."
            done
        else
            echo "$HOST was already not online."
        fi
    }

    start ()
    {
        if ! is_up
        then
            online=false
            try virsh start "$1" || failure
            while ! $online
            do
                if is_up
                then
                    online=true
                else
                    sleep 3
                fi
                echo "$HOST is online."
            done
        else
            echo "$HOST was already running."
        fi
    }

    restart ()
    {
        stop  "$HOST"
        start "$HOST"
    }

    echo "Trying to $OPTION $HOST"

    case "$OPTION" in
        "start"   ) start   "$HOST" ;;
        "stop"    ) stop    "$HOST" ;;
        "restart" ) restart "$HOST" ;;
    esac

    rm -rf "$TEST_FILE"
    rm -rf "$TMPFILE"
}
