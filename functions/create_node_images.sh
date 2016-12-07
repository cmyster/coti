create_node_images ()
{
    echo "creating images for each node"
    for (( index=0; index<${#NODES[@]}; index++ ))
    do
        eval DSK=\$${NODES[$index]}_DSK
        eval NUM=\$${NODES[$index]}_NUM
        eval DUM=\$${NODES[$index]}_DUM
        TOT=$(( NUM + DUM ))

        if [ $TOT -gt 0 ]
        then
            echo "creating an image disk for ${NODES[$index]}"
            case "${NODES[$index]}" in
            ceph)
                try qemu-img create -f raw ${NODES[$index]}.raw $(( ${DSK} / 2 ))G || failure
                for num in $(seq 0 $(( TOT - 1 )))
                do
                    cp ${NODES[$index]}.raw $VIRT_IMG/${NODES[$index]}-${num}_a.raw
                    cp ${NODES[$index]}.raw $VIRT_IMG/${NODES[$index]}-${num}_b.raw
                done
                ;;
            undercloud)
                try qemu-img create -f raw ${NODES[$index]}.raw ${DSK}G || failure
                try virt-resize -q --expand /dev/sda1 guest-image.raw ${NODES[$index]}.raw || failure
                for num in $(seq 0 $(( TOT - 1 )))
                do
                    cp ${NODES[$index]}.raw $VIRT_IMG/${NODES[$index]}-${num}.raw
                    virt-customize -q -a $VIRT_IMG/${NODES[$index]}-${num}.raw
                done
                ;;
            *)
                try qemu-img create -f raw ${NODES[$index]}.raw ${DSK}G || failure
                for num in $(seq 0 $(( TOT - 1 )))
                do
                    cp ${NODES[$index]}.raw $VIRT_IMG/${NODES[$index]}-${num}.raw
                done
                ;;
            esac
        fi
    done
}
