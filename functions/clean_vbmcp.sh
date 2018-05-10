clean_vbmcp()
{
    remove_vbmc_port ()
    {
        echo "Deleting virtual BMC port for ${1}."
        vbmc delete "$1" 2> /dev/null
    }

    if [ $# -gt 0 ]
    then
        remove_vbmc_port "$1"
    else
        for port in $(vbmc list 2> /dev/null | grep -v "+-\|Address" | awk '{print $2}')
        do
            remove_vbmc_port "$port"
        done
    fi

    echo "Restarting Virtual BMC service."
    try systemctl stop virtualbmc || failure
    pgrep vbmc | xargs kill
    try systemctl start virtualbmc || failure
}
