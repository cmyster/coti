post_uc_install_tweaks ()
{
    HOST=$1
    if [ ! -r default_gateway ]
    then
        echo "Default gateway was not saved."
        raise ${FUNCNAME[0]}
    fi

    DEFAULT_GATEWAY=$(cat default_gateway)
    if [ -z "$DEFAULT_GATEWAY" ]
    then
        echo "Default gateway was not set."
        raise ${FUNCNAME[0]}
    fi

    cat > post_uc_install_tweaks <<EOF
set -e
cd /home/stack/
source stackrc

BR_NAME="br-ctlplane"
BR_IP=\$(/usr/sbin/ifconfig \$BR_NAME | grep "inet " | awk '{print \$2}')
echo "\$BR_NAME ip is \$BR_IP"

DK_NET="docker0"
DK_IP=\$(/usr/sbin/ifconfig \$DK_NET | grep "inet " | awk '{print \$2}')
echo "\$DK_NET ip is \$DK_IP"

if [ -z $DEFAULT_GATEWAY ]; then exit 1; fi
if [ -z \$BR_IP ]; then exit 1; fi
if [ -z \$DK_IP ]; then exit 1; fi

# Copying SSH id to the default gateway.
for ip in $DEFAULT_GATEWAY \$BR_IP \$DK_IP
do
    sshpass -p $HOST_PASS ssh-copy-id root@\$ip &> /dev/null
done

# Testing passwordless SSH.
$SSH_CUST root@$DEFAULT_GATEWAY "echo hello"
$SSH_CUST root@\$BR_IP "echo hello"
$SSH_CUST root@\$DK_IP "echo hello"
EOF

run_script_file post_uc_install_tweaks stack $HOST /home/stack
}
