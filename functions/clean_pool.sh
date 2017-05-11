clean_pool ()
{
    echo "Stoping and undefining all pools."
    for pool in $(virsh pool-list | grep -v -e "Name.*State\|---\|^$" | awk '{print $1}')
    do
        echo "Cleaning ${pool}."
        try virsh pool-destroy $pool || failure
        try virsh pool-undefine $pool || failure
    done
}
