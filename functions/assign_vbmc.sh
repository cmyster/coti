assign_vbmc ()
{
    DEFAULT_GATEWAY=$(cat default_gateway)

    invs=( $(ls -1 *.inv | grep -v "${NODES[0]}") )
    if [ ${#invs[@]} -gt 0 ]
    then
        for inv in "${invs[@]}"
        do
            source "$inv"
            vbmc add "$name" --port "$pm_port" --username admin --password password --address ::ffff:$DEFAULT_GATEWAY
        done

        # Start right after add seems to be broken when running from a script,
        # so I want to at least exit the loop and do start.
        sleep 1
        for inv in "${invs[@]}"
        do
            source "$inv"
            vbmc start "$name"
        done

        # Now we need to make sure the ports are indeed running.
        sleep 1
        for inv in "${invs[@]}"
        do
            source "$inv"
            if ! vbmc show "$name" | grep running &> /dev/null
            then
                echo "$name VBMC port $pm_port is not running."
                exit 1
            fi
        done
    fi
}
