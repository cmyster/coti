define_nodes ()
{
    echo "Creating a definition file for each node."
    cp "$CWD"/vm-body "$WORK_DIR"

    VM_ID=1
    VBMCP=6320

    LETTER=( "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z" )

    try cp -af "$CWD"/templates "$WORK_DIR"/ || failure
    try cp -af "$CWD"/environments "$WORK_DIR"/ || failure

    for (( index=0; index<${#NODES[@]}; index++ ))
    do
        eval NUM="\$${NODES[$index]}"_NUM
        eval DUM="\$${NODES[$index]}"_DUM
        TOT=$(( NUM + DUM ))
        eval RAM="\$${NODES[$index]}"_RAM
        eval CPU="\$${NODES[$index]}"_CPU
        eval DSK="\$${NODES[$index]}"_DSK
        eval OSD="\$${NODES[$index]}"_OSD
        eval OHA="\$${NODES[$index]}"_OHA

        if [ $TOT -gt 0 ]
        then
            if [ ! -z "$OSD" ]
            then
                USE_OSD="OSD=$OSD"
            else
                USE_OSD=""
            fi

            for (( i=0; i<TOT; i++ ))
            do
                INV=${NODES[$index]}-$i.inv
                uuid=$(cat /proc/sys/kernel/random/uuid)
                echo "Defining ${NODES[$index]}-$i"
                {
                    echo "name=${NODES[$index]}-$i"
                    echo "cpu=$CPU"
                    echo "memory=$RAM"
                    echo "disk=$DSK"
                    echo "pm_port=$VBMCP"
                    echo "uuid=$uuid"
                    echo "$USE_OSD"
                } >> "$INV"
                echo "<domain type='kvm' id='$VM_ID'>" > "${NODES[$index]}"-${i}.xml
                VM_ID=$(( VM_ID + 1 ))
                VBMCP=$(( VBMCP + 1 ))
                cat >> "${NODES[$index]}"-${i}.xml <<EOF
  <name>${NODES[$index]}-$i</name>
  <uuid>$uuid</uuid>
  <memory unit='KiB'>$(( RAM * 1024 ))</memory>
  <vcpu placement='static'>$CPU</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
    <boot dev='hd'/>
  </os>
EOF

                cat vm-body >> "${NODES[$index]}"-${i}.xml

                # in case of ceph there are more disks
                if [[ "${NODES[$index]}" == "ceph" ]]
                then
                    cat >> "${NODES[$index]}"-${i}.xml <<EOF
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source file='$VIRT_IMG/${NODES[$index]}-${i}.raw'/>
      <target dev='vda' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x01' function='0x0'/>
    </disk>
EOF
                    for ha in $(seq 0 $(( OHA - 1 )))
                    do
                        cat >> "${NODES[$index]}"-${i}.xml <<EOF
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source file='$VIRT_IMG/${NODES[$index]}-${i}_osd${ha}.raw'/>
      <target dev='vd${LETTER[$ha]}' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x03' slot='0x0$(( ha + 1 ))' function='0x0'/>
    </disk>
EOF
                        cat >> environments/ceph_devices.yaml <<EOF
            - '/dev/vd${LETTER[$ha]}'
EOF
                    done
                else
                    cat >> "${NODES[$index]}"-${i}.xml <<EOF
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source file='$VIRT_IMG/${NODES[$index]}-${i}.raw'/>
      <target dev='vda' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x01' function='0x0'/>
    </disk>
EOF
                fi

                n=1
                for vnet in "${NETWORKS[@]}"
                do
                    mac=$(hexdump -n3 -e'/3 "52:51:0'$n'" 3/1 ":%02x"' /dev/urandom)
                    echo "$vnet=$mac" >> "$INV"
                    cat >> "${NODES[$index]}"-${i}.xml <<EOF
    <interface type='network'>
      <mac address='$mac'/>
      <source network='$vnet'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x0$n' function='0x0'/>
    </interface>
EOF
                    n=$(( n + 1 ))
                done

                if [ $index -eq 0 ]
                then
                    mac=$(hexdump -n3 -e'/3 "52:52:0'$n'" 3/1 ":%02x"' /dev/urandom)
                    echo "default=$mac" >> "$INV"
                    cat >> "${NODES[$index]}"-${i}.xml <<EOF
    <interface type='network'>
      <mac address='$mac'/>
      <source network='default'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x05' slot='0x01' function='0x0'/>
    </interface>
EOF
                fi

                cat >> "${NODES[$index]}"-${i}.xml <<EOF
  </devices>
</domain>
EOF

            define_vm "${NODES[$index]}"-${i}
            done
        fi
    done
}
