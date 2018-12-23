post_uc_install_tweaks ()
{
    HOST=$1
    if [ ! -r default_gateway ]
    then
        echo "Default gateway was not saved."
        raise "${FUNCNAME[0]}"
    fi

    DEFAULT_GATEWAY=$(cat default_gateway)
    if [ -z "$DEFAULT_GATEWAY" ]
    then
        echo "Default gateway was not set."
        raise "${FUNCNAME[0]}"
    fi

    # Need to know what is the hard coded IP looks like...
    ssh undercloud-0 ls -l &> /dev/null <<EOF


EOF
    cat > post_uc_install_tweaks_root <<EOF
set -e

# Make sure we're up-to-date.
yum update -y

# Install ceph-ansible.
yum install -y ceph-ansible &> /dev/null

# Saving the IPs set for br-ctlplane and docker0.
rm -rf ctlplane-addr docker0-addr
/usr/sbin/ip a | grep -A10 "br-ctlplane:" | grep "inet " | awk '{print \$2}' | cut -d "/" -f 1 | sort | tr "\\n" " "  > /home/stack/ctlplane-addr
/usr/sbin/ip a | grep -A4 "docker0:" | grep "inet " | awk '{print \$2}' | cut -d "/" -f 1 | sort | tr "\\n" " " > /home/stack/docker0-addr
chown stack:stack /home/stack/ctlplane-addr /home/stack/docker0-addr
if [ ! -f /home/stack/ctlplane-addr ]
then
    exit 1
fi
BR_IP=\$(cut -d " " -f 1 /home/stack/ctlplane-addr)
DK_IP=\$(cut -d " " -f 1 /home/stack/docker0-addr)

if [ -z $DEFAULT_GATEWAY ]; then exit 1; fi

# If there is no ssh pub file, create it.
if [ ! -r /root/.ssh/id_rsa ]
then
    ssh-keygen -t rsa -N "" -f "/root/.ssh/id_rsa"
fi

# Copying SSH ids.
for ip in $DEFAULT_GATEWAY \$(cat /home/stack/ctlplane-addr) \$(cat /home/stack/docker0-addr) $HOST_IP
do
    sshpass -p $HOST_PASS ssh-copy-id root@\$ip &> /dev/null
done

# Testing passwordless SSH.
for ip in $DEFAULT_GATEWAY \$(cat /home/stack/ctlplane-addr) \$(cat /home/stack/docker0-addr) 
do
    $SSH_CUST root@\$ip "echo hello"
done
EOF

    run_script_file post_uc_install_tweaks_root root "$HOST" /root

    # stack user needs some passwordless SSH love as well.
    cat > post_uc_install_tweaks_stack <<EOF
set -e
cd /home/stack

# Copying SSH ids.
for ip in $DEFAULT_GATEWAY \$(cat /home/stack/ctlplane-addr) \$(cat /home/stack/docker0-addr)
do
    sshpass -p $HOST_PASS ssh-copy-id root@\$ip &> /dev/null
done

# Testing passwordless SSH.
for ip in $DEFAULT_GATEWAY \$(cat /home/stack/ctlplane-addr) \$(cat /home/stack/docker0-addr) 
do
    $SSH_CUST root@\$ip "echo hello"
done
EOF

    run_script_file post_uc_install_tweaks_stack stack "$HOST" /home/stack

    # Save admin's password locally
    $SSH_CUST stack@$HOST "source /home/stack/stackrc && sudo hiera admin_password" > admin_password
    $SSH_CUST stack@$HOST "cat /home/stack/ctlplane-addr" > ctlplane-addr
}
