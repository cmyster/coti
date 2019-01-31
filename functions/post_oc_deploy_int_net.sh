post_oc_deploy_int_net()
{
    HOST=$1
    nets=${#NETWORKS[@]}
    ext_net=${NETWORKS[$(( nets - 1 ))]}
    invs=$(ls -1 *.inv | grep -v "${NODES[0]}")

    for inv in $invs
    do
        . $inv
        eval host="$name"
        echo int_ip=$($SSH_CUST $HOST "grep $host /etc/hosts" | cut -d " " -f 1) >> $inv
    done
}
