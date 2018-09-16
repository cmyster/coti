clean_vbmcd()
{
    remove_vbmc_port ()
    {
        echo "Deleting virtual BMC port for ${1}."
        if pgrep vbmc &> /dev/null
        then
            vbmc delete "$1" 2> /dev/null
        fi
    }

    if [ $# -gt 0 ]
    then
        remove_vbmc_port "$1"
    else
        for port in $(/usr/bin/python /usr/bin/vbmc list | grep -v "+-\|Address" | awk '{print $2}')
        do
            remove_vbmc_port "$port"
        done
    fi

    echo "Restarting Virtual BMC service."
    if pgrep vbmc &> /dev/null
    then
        killall vbmc
    fi
    if pgrep vbmcd &> /dev/null
    then
        killall vbmcd
    fi
    try vbmcd || failure
}
