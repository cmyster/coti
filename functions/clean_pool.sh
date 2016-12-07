clean_pool ()
{
    echo "stoping and undefining all pools"
    for pool in $(virsh pool-list | grep -v -e "Name.*State\|---\|^$" | awk '{print $1}')
    do
        echo "cleaning $pool"
        try virsh pool-destroy $pool || failure
        try virsh pool-undefine $pool || failure
    done
}
