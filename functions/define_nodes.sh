define_nodes ()
{
    echo "creating a definition file for each node"
    cp $CWD/vm-body $WORK_DIR

    VM_ID=1

    for (( index=0; index<${#NODES[@]}; index++ ))
    do
        eval NUM=\$${NODES[$index]}_NUM
        eval DUM=\$${NODES[$index]}_DUM
        TOT=$(( NUM + DUM ))
        eval RAM=\$${NODES[$index]}_RAM
        eval CPU=\$${NODES[$index]}_CPU
        eval DSK=\$${NODES[$index]}_DSK
        eval OS=\$${NODES[$index]}_OS

        if [ $TOT -gt 0 ]
        then
            for (( i=0; i<$TOT; i++ ))
            do
                INV=${NODES[$index]}-$i.inv
                echo "defining ${NODES[$index]}-$i"
                echo "name=${NODES[$index]}-$i" >> $INV
                echo "cpu=$CPU" >> $INV
                echo "memory=$RAM" >> $INV
                echo "disk=$DSK" >> $INV
                uuid=$(cat /proc/sys/kernel/random/uuid)
                echo "uuid=$uuid" >> $INV
                echo "<domain type='kvm' id='$VM_ID'>" > ${NODES[$index]}-${i}.xml
                VM_ID=$(( VM_ID + 1 ))

                cat >> ${NODES[$index]}-${i}.xml <<EOF
  <name>${NODES[$index]}-$i</name>
  <uuid>$uuid</uuid>
  <memory unit='KiB'>$(( $RAM * 1024 ))</memory>
  <vcpu placement='static'>$CPU</vcpu>
  <os>
    <type arch='x86_64' machine='pc-i440fx-$OS'>hvm</type>
    <boot dev='hd'/>
  </os>
EOF

                cat vm-body >> ${NODES[$index]}-${i}.xml

                # in case of ceph there are two disks
                if [[ ${NODES[$index]} == "ceph" ]]
                then
                    cat >> ${NODES[$index]}-${i}.xml <<EOF
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source file='/var/lib/libvirt/images/${NODES[$index]}-${i}_a.raw'/>
      <target dev='vda' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x01' function='0x0'/>
    </disk>
EOF
                    cat >> ${NODES[$index]}-${i}.xml <<EOF
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source file='/var/lib/libvirt/images/${NODES[$index]}-${i}_b.raw'/>
      <target dev='vdb' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x02' function='0x0'/>
    </disk>
EOF
                else
                    cat >> ${NODES[$index]}-${i}.xml <<EOF
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source file='/var/lib/libvirt/images/${NODES[$index]}-${i}.raw'/>
      <target dev='vda' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x01' function='0x0'/>
    </disk>
EOF
                fi

                n=1
                for vnet in ${NETWORKS[@]}
                do
                    mac=$(hexdump -n3 -e'/3 "52:51:0'$n'" 3/1 ":%02x"' /dev/urandom)
                    echo "$vnet=$mac" >> $INV
                    cat >> ${NODES[$index]}-${i}.xml <<EOF
    <interface type='network'>
      <mac address='$mac'/>
      <source network='$vnet'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x02' slot='0x0$n' function='0x0'/>
    </interface>
EOF
                    n=$(( n + 1 ))
                done

                if [ $index -eq 0 ]
                then
                    mac=$(hexdump -n3 -e'/3 "52:52:0'$n'" 3/1 ":%02x"' /dev/urandom)
                    echo "default=$mac" >> $INV
                    cat >> ${NODES[$index]}-${i}.xml <<EOF
    <interface type='network'>
      <mac address='$mac'/>
      <source network='default'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x03' slot='0x01' function='0x0'/>
    </interface>
EOF
                fi

                cat >> ${NODES[$index]}-${i}.xml <<EOF
  </devices>
</domain>
EOF

            define_vm ${NODES[$index]}-${i}
            done
        fi
    done
}
