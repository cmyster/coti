populate_hosts ()
{
    HOST=$1
    cat > populate_hosts <<EOF
#!/bin/bash
echo "# coti" >> /etc/hosts
cd /home/stack
source stackrc
openstack server list -f value \\
    | awk '{print \$4" "\$2}' \\
    | sed 's/ctlplane=//g' \\
    | sed 's/overcloud-//g' \\
    | sort -k2 >> /etc/hosts \\
    | sed 's/storage//g'
EOF
    run_script_file populate_hosts root "$HOST" /root
}
