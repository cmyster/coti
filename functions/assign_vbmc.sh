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
            vbmc add $name --port $pm_port --username admin --password password 2> /dev/null
        done
    fi
}
