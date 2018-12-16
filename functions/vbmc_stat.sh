vbmc_stat ()
{
    invs=( $(ls -1 *.inv | grep -v "${NODES[0]}") )
    if [ ${#invs[@]} -gt 0 ]
    then
        for inv in "${invs[@]}"
        do
            source "$inv"
            if ! vbmc show "$name" | grep "$1" &> /dev/null
            then
                echo "$name VBMC port is not in "$1" status."
                raise "${FUNCNAME[0]}"
            fi
        done
    fi
}
