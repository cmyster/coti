clean_vbmc()
{
    for port in $(vbmc list | grep -v "+-\|Address" | awk '{print $2}' | grep -v "^$")
    do
        if [ ! -z "$port" ]
        then
            echo "Deleting virtual BMC port for $port."
            vbmc stop "$port" &> /dev/null
            vbmc delete "$port" &> /dev/null
        fi
    done

    sleep 3

    echo "Searching and stopping stagnant vbmc processes."
    if pgrep -a vbmc
    then
        for pid in $(pgrep -a vbmc | awk '{print $1}')
        do
            kill $pid
            if ps -o pid= -p $pid &> /dev/null
            then
                echo "Couldn't stop ${pid}."
                raise "${FUNCNAME[0]}"
            fi
        done
    fi
}
