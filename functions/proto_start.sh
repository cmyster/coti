proto_start ()
{
    try virt-install --ram 8192 --vcpus 4 --os-variant rhel7 --disk path=$VIRT_IMG/proto.qcow2,device=disk,bus=virtio,format=qcow2 --import --noautoconsole --vnc --network network:default --name proto || failure

    echo "Prepering a proto so it will be easier to install undercloud later."

    PROTO_STATE=$(virsh dominfo proto | grep State | awk '{print $2}')
    counter=1
    while [[ "$PROTO_STATE" == "running" ]]
    do
        case counter in
            360)
                echo "This is taking too long, trying to shut down."
                virsh shutdown proto
                ;;
            365)
                echo "This is taking far too long, forcing a shut down."
                virsh destroy proto
                ;;
        esac
        sleep 10
        PROTO_STATE=$(virsh dominfo proto | grep State | awk '{print $2}')
        counter=$(( counter + 1 ))
    done

    if [ $counter -lt 359 ]
    then
        echo "Proto went down on its own."
    else
        echo "Proto was closed by the script."
    fi
}
