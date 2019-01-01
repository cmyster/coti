define_nodes ()
{
    echo "Creating a definition file for each node."
    cp "$CWD"/vm-body "$WORK_DIR"

    VM_ID=1
    VBMCP=6320

    try cp -af "$CWD"/templates "$WORK_DIR"/ || failure
    try cp -af "$CWD"/environments "$WORK_DIR"/ || failure

    # For each node type in NODES:
    for (( index=0; index<${#NODES[@]}; index++ ))
    do
        # Reading node definition.
        eval NUM="\$${NODES[$index]}"_NUM
        eval DUM="\$${NODES[$index]}"_DUM
        TOT=$(( NUM + DUM ))
        eval RAM="\$${NODES[$index]}"_RAM
        eval CPU="\$${NODES[$index]}"_CPU
        eval DSK="\$${NODES[$index]}"_DSK
        eval SDX="\$${NODES[$index]}"_SDX

        # If we need to actualy create a node:
        if [ $TOT -gt 0 ]
        then
            # for each node of a specific type:
            for (( i=0; i<TOT; i++ ))
            do
                # These are the files where definitions are saved per node.
                INV=${NODES[$index]}-${i}.inv
                XML=${NODES[$index]}-${i}.xml
                uuid=$(cat /proc/sys/kernel/random/uuid)
                echo "Defining ${NODES[$index]}-$i"
                {
                    echo "name=${NODES[$index]}-$i"
                    echo "cpu=$CPU"
                    echo "memory=$RAM"
                    echo "disk=$DSK"
                    echo "pm_port=$VBMCP"
                    echo "uuid=$uuid"
                } >> "$INV"

                # Starting to define an XML that libvirt can read.
                echo "<domain type='kvm' id='$VM_ID'>" > "$XML"
                VM_ID=$(( VM_ID + 1 ))
                VBMCP=$(( VBMCP + 1 ))
                cat >> "$XML" <<EOF
  <name>${NODES[$index]}-$i</name>
  <uuid>$uuid</uuid>
  <memory unit='KiB'>$(( RAM * 1024 ))</memory>
  <vcpu placement='static'>$CPU</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
    <boot dev='hd'/>
  </os>
EOF
                # Adding some constants that doesn't need to be generated.
                cat vm-body >> "$XML"

                # Adding disk device blocks.
                for d in $(seq 0 $((SDX - 1)))
                do
                    cat >> "$XML" <<EOF
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source file='$VIRT_IMG/${NODES[$index]}-${i}_${d}.raw'/>
      <target dev='vd${LETTERS[${d}]}' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x03' slot='0x0$(( d + 1 ))' function='0x0'/>
    </disk>
EOF
                done

                # Adding networking device blocks.
                n=1
                # If this is the Undercloud it needs only the 
                # ControlPlane, External and libvirt's default networks.
                if [ $index -eq 0 ]
                then
                    nets=${#NETWORKS[@]}                                                                                                                                                    │·······
                    vnet_ctl="${NETWORKS[0]}"
                    vnet_ext="${NETWORKS[$(( nets - 1 ))]}"
                    mac_ctl=$(hexdump -n3 -e'/3 "52:51:01" 3/1 ":%02x"' /dev/urandom)
                    mac_ext=$(hexdump -n3 -e'/3 "52:51:02" 3/1 ":%02x"' /dev/urandom)
                    mac_def=$(hexdump -n3 -e'/3 "52:51:03" 3/1 ":%02x"' /dev/urandom)
                    echo "${vnet_ctl}=${mac_ctl}" >> "$INV"
                    echo "${vnet_ext}=${mac_ext}" >> "$INV"
                    echo "default=${mac_def}" >> "$INV"
                    cat >> "$XML" <<EOF
    <interface type='network'>
      <mac address='$mac_ctl'/>
      <source network='$vnet_ctl'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x01' function='0x0'/>
    </interface>
    <interface type='network'>
      <mac address='$mac_ext'/>
      <source network='$vnet_ext'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x02' function='0x0'/>
    </interface>
    <interface type='network'>
      <mac address='$mac_def'/>
      <source network='default'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x03' function='0x0'/>
    </interface>
EOF
                else
                    for vnet in "${NETWORKS[@]}"
                    do
                        mac=$(hexdump -n3 -e'/3 "52:51:0'$n'" 3/1 ":%02x"' /dev/urandom)
                        echo "$vnet=$mac" >> "$INV"
                        cat >> "$XML" <<EOF
    <interface type='network'>
      <mac address='$mac'/>
      <source network='$vnet'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x0$n' function='0x0'/>
    </interface>
EOF
                        n=$(( n + 1 ))
                    done
                fi

                # Finally, closing the file.
                cat >> "$XML" <<EOF
  </devices>
</domain>
EOF
                # While here, I can add OSDs to the ceph environment.
                if [[ "${NODES[$index]}" == "ceph" ]]
                then
                    for d in $(seq 1 $(( SDX -1 )))
                    do
                        cat >> environments/ceph_devices.yaml <<EOF
            - '/dev/vd${LETTERS[$d]}'
EOF
                    done
                    # Finally we need to define the scenario.
                        cat >> environments/ceph_devices.yaml <<EOF
        osd_scenario: collocated
EOF

                fi
            define_vm "${NODES[$index]}"-${i}
            done
        fi
    done
}
