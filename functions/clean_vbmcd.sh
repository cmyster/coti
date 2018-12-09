clean_vbmcd()
{
    remove_vbmc_port ()
    {
        echo "Deleting virtual BMC port for ${1}."
        try vbmc stop "$1" || failure
        try vbmc delete "$1" || failure
    }

    for port in $(vbmc list | grep -v "+-\|Address" | awk '{print $2}' | grep -v "^$")
    do
        remove_vbmc_port "$port"
    done

    echo "Restarting Virtual BMC service."
    ps -ef | grep vbmcd | grep -v grep | awk '{print $2}' | xargs kill &> /dev/null
    try vbmcd || failure
}
