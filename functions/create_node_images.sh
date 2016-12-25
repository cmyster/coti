create_node_images ()
{
    echo "creating images for each node"
    for (( index=0; index<${#NODES[@]}; index++ ))
    do
        eval DSK=\$${NODES[$index]}_DSK
        eval NUM=\$${NODES[$index]}_NUM
        eval DUM=\$${NODES[$index]}_DUM
        eval OSD=\$${NODES[$index]}_OSD
        TOT=$(( NUM + DUM ))

        if [ $TOT -gt 0 ]
        then
            echo "creating an image disk for ${NODES[$index]}"
            case "${NODES[$index]}" in
            ceph)
                try qemu-img create -f raw ${NODES[$index]}.raw ${DSK}G || failure
                try qemu-img create -f raw ${NODES[$index]}_osd.raw ${OSD}G || failure
                for num in $(seq 0 $(( TOT - 1 )))
                do
                    cp ${NODES[$index]}.raw $VIRT_IMG/${NODES[$index]}-${num}.raw
                    cp ${NODES[$index]}_osd.raw $VIRT_IMG/${NODES[$index]}-${num}_osd.raw
                done
                ;;
            undercloud)
                try qemu-img create -f raw ${NODES[$index]}.raw ${DSK}G || failure
                try virt-resize -q --expand /dev/sda1 guest-image.raw ${NODES[$index]}.raw || failure
                for num in $(seq 0 $(( TOT - 1 )))
                do
                    cp ${NODES[$index]}.raw $VIRT_IMG/${NODES[$index]}-${num}.raw
                    virt-customize -m 4096 --smp 4 -q -a $VIRT_IMG/${NODES[$index]}-${num}.raw
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
