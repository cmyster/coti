clean_vbmcp()
{
    remove_vbmcp ()
    {
        echo "Deleting virtual BMC port for ${1}."
        vbmc delete "$1" 2> /dev/null
    }

    if [ $# -gt 0 ]
    then
        remove_vbmcp "$1"
    else
        for vbmcp in $(vbmc list 2> /dev/null | grep -v "+-\|Address" | awk '{print $2}')
        do
            remove_vbmcp "$vbmcp"
        done
    fi
}
