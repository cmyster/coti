vbmc_add ()
{
    DEFAULT_GATEWAY=$(cat default_gateway)

    invs=( $(ls -1 *.inv | grep -v "${NODES[0]}") )
    if [ ${#invs[@]} -gt 0 ]
    then
        for inv in "${invs[@]}"
        do
            source "$inv"
            try vbmc add "$name" --port "$pm_port" --username admin --password password --address ::ffff:$DEFAULT_GATEWAY || failure
        done
    fi

    # VBMC ports take time to give proper status.
    # I am sleeping here before continuing.
    sleep 30
}
