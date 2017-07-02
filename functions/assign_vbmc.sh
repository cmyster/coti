assign_vbmc ()
{
    invs=( $(ls -1 *.inv | grep -v ${NODES[0]}) )
    if [ ${#invs[@]} -gt 0 ]
    then
        for inv in ${invs[@]}
        do
            source $inv
            vbmc delete $name 2> /dev/null
        done
        for inv in ${invs[@]}
        do
            source $inv
            vbmc add $name --port $pm_port --username admin --password password --libvirt-uri qemu:///$HOST_IP 2> /dev/null
            vbmc start $pm_port
        done
    fi
}
