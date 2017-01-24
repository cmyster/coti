populate_hosts ()
{
    HOST=$1
    cat > populate_hosts <<EOF
#!/bin/bash
cd /home/stack
source stackrc
openstack server list -f value \\
  | awk '{print \$4" "\$2}' \\
  | sed 's/ctlplane=//g' \\ 
  | sed 's/overcloud-//g' \\
  | sort -rk2 >> /etc/hosts
EOF
    run_script_file populate_hosts root $HOST /root
}
