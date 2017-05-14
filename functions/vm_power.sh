vm_power ()
{
    HOST=$1
    OPTION=$2

    # Test string for nc to send. Its supposed to fail the SSH handshake.
    TEST_FILE="nc_test_string_$HOST"
    TMPFILE="nc_tmpfile_$HOST"
    EXE="nc -w 1 $1 22"
    echo "Hello, is it me you're looking for?" > $TEST_FILE

    if [ -z $HOST ] || [ -z $OPTION ]
    then
        raise ${FUNCNAME[0]}
    fi

    is_conn ()
    {
        nc -w 1 $1 22 < $TEST_FILE &> $TMPFILE
        grep OpenSSH $TMPFILE &> /dev/null
        case $? in
            0) return 0 ;;
            *) return 1 ;;
        esac
    }

    wait_off ()
    {
        $SSH root@$1 "shutdown -hP -t 0 now" &> /dev/null &
        # skipping connection testing till I can fix it
#        ITR=50
#        for i in $(seq 0 $ITR)
#        do
#            if [ $i -eq $ITR ]
#            then
#                echo "$1 did not go down within the allowed time"
#                raise ${FUNCNAME[0]}
#            fi
#
#            if ! is_conn $1
#            then
#                echo "$1 is offline"
#                return 0
#            else
#                sleep 10
#            fi
#        done
    }

    wait_on ()
    {
        try virsh start $1 || failure
        # skipping connection testing till I can fix it
#        ITR=50
#        for i in $(seq 0 $ITR)
#        do
#            if [ $i -eq $ITR ]
#            then
#                echo "$1 did not go up within the allowed time"
#                raise ${FUNCNAME[0]}
#            fi
#            if is_conn $1
#            then
#                echo "$1 is online"
#                return 0
#            else
#                sleep 10
#            fi
#        done
    }

    wait_reboot ()
    {
        wait_off $1
        wait_on  $1
    }

    echo "Trying to $2 $HOST"

    case "$2" in
        "start"   ) wait_on     $HOST ;;
        "stop"    ) wait_off    $HOST ;;
        "restart" ) wait_reboot $HOST ;;
    esac

    rm -rf $TEST_FILE
    rm -rf $TMPFILE
}
