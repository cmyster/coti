pre_uc_install_wa ()
{
    # Workarounds needed prior undercloud install.

    HOST=$1

    # Workarounds that are needed to be run inside a node go in this script:
    echo "Running pre-undercloud install workarounds."
    cat > pre_uc_install_wa <<EOF
### Workrounds go here
# =====================================================================
### This is to avoid some dependancy hell.
for pack in "iptables" "subscription-manager" "bigswitch"
do
    if rpm -qa | grep \$pack
    then
        rpm -qa | grep \$pack | xargs sudo rpm -e --nodeps
    fi
done
sudo yum install -y subscription-manager iptables
# =====================================================================
### Self Signed IT CA needs to be refreshed
cd /etc/pki/ca-trust/source/anchors
sudo wget https://password.corp.redhat.com/RH-IT-Root-CA.crt
update-ca-trust
# =====================================================================
### End of workarounds
EOF

    run_script_file pre_uc_install_wa stack "$HOST" /home/stack

    # Workarounds that work from outside the nodes go here:
}
