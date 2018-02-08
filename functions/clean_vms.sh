clean_vms ()
{
    # I don't do try || failure in the destroy because it gives false
    # negatives if trying to destroy an offline VM.

    remove_vm ()
    {
        IMG=$(virsh dumpxml "$1" | grep "source file" | tr "'" " " | awk '{print $3}')
        echo Removing "$1"
        virsh destroy "$1" &> /dev/null
        try virsh undefine "$1" &> /dev/null || failure
        rm -rf "$IMG"
    }

    if [ $# -gt 0 ]
    then
        for vm in "$@"
        do
            remove_vm "$vm"
        done
    else
        echo "Stopping and removing all currently defined VMs." 
        for vm in $(virsh list --all | awk '{print $2}' | grep -v "^$\|Name")
        do
            remove_vm "$vm"
        done
    fi
}
