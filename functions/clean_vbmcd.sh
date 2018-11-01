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

    if ps -ef | grep vbmcd | grep -v grep &> /dev/null
    then
        for port in $(/usr/bin/python /usr/bin/vbmc list | grep -v "+-\|Address" | awk '{print $2}' | grep -v "^$")
        do
            remove_vbmc_port "$port"
        done
    fi

    echo "Restarting Virtual BMC service."
    ps -ef | grep vbmcd | grep -v grep | awk '{print $2}' | xargs kill &> /dev/null
    try vbmcd || failure
}
