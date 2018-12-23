clean_vbmc()
{
    # If the VBMC daemon is down, start it, otherwise vbmc list will freeze.
    #if ! pgrep -a vbmcd &> /dev/null
    #then
    #    vbmcd
    #fi

    #for port in $(vbmc list | grep -v "+-\|Address" | awk '{print $2}' | grep -v "^$")
    #do
    #    if [ ! -z "$port" ]
    #    then
    #        echo "Deleting vbmc port for $port."
    #        vbmc stop "$port" &> /dev/null
    #        vbmc delete "$port" &> /dev/null
    #    fi
    #done

    #echo "Killing vbmcd."
    #pgrep -a vbmcd | awk '{print $1}' | xargs kill

    #sleep 3

    echo "Searching and stopping vbmc processes."
    if pgrep -a vbmc &> /dev/null
    then
        for pid in $(ps -ef | grep vbmc | grep -v grep | awk '{print $2}')
        do
            kill -9 $pid
            if ps -o pid= -p $pid &> /dev/null
            then
                echo "Couldn't stop ${pid}."
                raise "${FUNCNAME[0]}"
            fi
        done
    fi
    rm -rf /root/.vbmc
}
