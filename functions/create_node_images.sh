create_node_images ()
{
    echo "Creating images for each node."
    if [ ! -d "$WORK_DIR/appliance" ]
    then
        get_appliance
    fi

    for (( index=0; index<${#NODES[@]}; index++ ))
    do
        eval DSK="\$${NODES[$index]}"_DSK
        eval NUM="\$${NODES[$index]}"_NUM
        eval DUM="\$${NODES[$index]}"_DUM
        eval SDX="\$${NODES[$index]}"_SDX

        TOT=$(( NUM + DUM ))

        if [ $TOT -gt 0 ]
        then
            echo "Creating an image disk for ${NODES[$index]}"
            # Creating an initial disk in the required size for this node.
            try qemu-img create -f raw "${NODES[$index]}".raw "${DSK}"G || failure

            # For the undercloud machine, we need to expand the guest image on top of the created image.
            if [[ "${NODES[$index]}" == "undercloud" ]]
            then
                try virt-resize -q --expand /dev/sda1 guest-image.raw "${NODES[$index]}".raw || failure
        #        try virt-customize "$VIRSH_CUST" -a "${NODES[$index]}".raw || failure
            fi
            for node in $(seq 0 $(( TOT - 1 )))
            do
                for disk in $(seq 0 $(( SDX - 1 )))
                do
                    cp "${NODES[$index]}".raw "$VIRT_IMG/${NODES[$index]}-${node}_${disk}".raw
                done
            done
        fi
    done
}
