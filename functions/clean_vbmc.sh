clean_vbmc()
{
    for port in $(vbmc list | grep -v "+-\|Address" | awk '{print $2}' | grep -v "^$")
    do
        if [ ! -z "$port" ]
        then
            echo "Deleting virtual BMC port for $port."
            try vbmc stop "$port" || failure
            try vbmc delete "$port" || failure
        fi
    done

    echo "Sleeping to all port deletion before verifying removal."
    sleep 30

    for port in $(vbmc list | grep -v "+-\|Address" | awk '{print $2}')
    do
        if [ ! -z $port ]
        then
            echo "VBMC port $port was not deleted."
            raise "${FUNCNAME[0]}"
        fi
    done
}
