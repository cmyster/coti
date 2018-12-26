vbmc_add ()
{
    DEFAULT_GATEWAY=$(cat default_gateway)

    if ! pgrep vbmcd
    then
        try vbmcd || failure
    fi

    invs=( $(ls -1 *.inv | grep -v "${NODES[0]}") )
    if [ ${#invs[@]} -gt 0 ]
    then
        for inv in "${invs[@]}"
        do
            source "$inv"
            try vbmc add "$name" --port "$pm_port" --username admin --password password --address ::ffff:$DEFAULT_GATEWAY || failure
        done
    fi
}
