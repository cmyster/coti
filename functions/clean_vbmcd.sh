clean_vbmcd()
{
    remove_vbmc_port ()
    {
        echo "Deleting virtual BMC port for ${1}."
        try vbmc stop "$1" || failure
        try vbmc delete "$1" || failure
        if vbmc show "$1" &> /dev/null
        then
            echo "VBMC port for $1 was not deleted."
            raise "${FUNCNAME[0]}"
        fi
    }

    for port in $(vbmc list | grep -v "+-\|Address" | awk '{print $2}' | grep -v "^$")
    do
        remove_vbmc_port "$port"
    done
}
