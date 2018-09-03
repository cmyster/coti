assign_vbmc ()
{
    invs=( $(ls -1 *.inv | grep -v "${NODES[0]}") )
    if [ ${#invs[@]} -gt 0 ]
    then
        DEFAULT_GATEWAY=$(cat default_gateway)
        for port in $(vbmc list -f value | cut -d " " -f 1)
        do
            vbmc delete "$port"
        done

        for inv in "${invs[@]}"
        do
            source "$inv"
            vbmc add "$name" --port "$pm_port" --username admin --password password --libvirt-uri qemu:///system --address "::ffff:${DEFAULT_GATEWAY}"
            vbmc start "$name"
        done
    fi
}
