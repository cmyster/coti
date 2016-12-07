create_vnet ()
{
    echo "Defining and starting virtual networks."
    nets=${#NETWORKS[@]}

    for (( index=0; index<$nets; index++ ))
    do
        echo "Defining ${NETWORKS[ $index ]}."
        cat > ${NETWORKS[ $index ]}.xml <<EOF
<network>
  <name>${NETWORKS[ $index ]}</name>
  <ip address="10.$(( $index + 1 ))0.0.1" netmask="255.255.255.0"/>
</network>
EOF
        try virsh net-define ${NETWORKS[ $index ]}.xml || failure
        try virsh net-start ${NETWORKS[ $index ]} || failure
        try virsh net-autostart ${NETWORKS[ $index ]} || failure
    done

    DEFAULT_GATEWAY=$(virsh net-dumpxml ${NETWORKS[0]} | grep "ip address" | tr "'" " "  | awk '{print $3}')
}
