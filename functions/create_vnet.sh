create_vnet ()
{
    echo "Defining and starting virtual networks."
    nets=${#NETWORKS[@]}

    for (( index=1; index<$nets; index++ ))
    do
        cat > net-${NETWORKS[ $index ]}.xml <<EOF
<network>
  <name>${NETWORKS[ $index ]}</name>
  <ip address="10.${index}0.0.1" netmask="255.255.255.0"/>
</network>
EOF
    done

    EXT_NET=$(ls -1 net*.xml | grep -i ext)
    sed -i 2i"<forward mode='nat'><nat><port start='1024' end='65535'/></nat></forward>" $EXT_NET
    sed -i 3i"<dhcp><range start='10.${nets}0.0.${DHCP_OUT_START}' end='10.${nets}0.0.${DHCP_OUT_END}'/></dhcp>" $EXT_NET

    for xml in $(ls -1 net*.xml)
    do
        echo "Defining ${xml}."
        try virsh net-define $xml || failure
    done

    for net in $(virsh net-list --all | grep inactive | awk '{print $1}')
    do
        echo "Starting ${net}."
        try virsh net-start $net || failure
        try virsh net-autostart $net || failure
    done

    DEFAULT_GATEWAY=$(virsh net-dumpxml ${NETWORKS[0]} | grep "ip address" | tr "'" " "  | awk '{print $3}')
}
