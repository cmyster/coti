vbmc_start ()
{
    invs=( $(ls -1 *.inv | grep -v "${NODES[0]}") )
    if [ ${#invs[@]} -gt 0 ]
    then
        for inv in "${invs[@]}"
        do
            source "$inv"
            try vbmc start "$name" || failure
        done
    fi

    # VBMC ports take time to give proper status.                             
    # I am sleeping here before continuing.                                   
    sleep 30
}
