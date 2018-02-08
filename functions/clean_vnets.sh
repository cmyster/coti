clean_vnets ()
{
    remove_vnet ()
    {
        echo "Clearing virtual network: $1"
        if virsh net-list --all | grep "$1" | grep " active" &> /dev/null
        then
            try virsh net-destroy "$1" &> /dev/null || failure
        fi
        try virsh net-undefine "$1" &> /dev/null || failure
    }

    if [ $# -gt 0 ]
    then
        for vnet in "$@"
        do
            echo "Removing ${vnet}."
            remove_vnet "$vnet"
        done
    else
        echo "Stopping and undefining all virtual networks."
        for vnet in $(virsh net-list --all | grep -v default | grep -v -e "Name.*State\|---\|^$" | awk '{print $1}')
        do
            remove_vnet "$vnet"
        done

        for br in $(brctl show | sed 1d | awk '{print $1}')
        do
            echo "Clearing virtual bridge: $br"
            try ifconfig "$br" down || failure
            try brctl delbr "$br" &> /dev/null || failure
        done

        for br in $(ovs-vsctl list-br 2> /dev/null)
        do
            echo "Clearing ovs bridge: $br"
            try ovs-vsctl del-br "$br" &> /dev/null || failure
        done
    fi
}
