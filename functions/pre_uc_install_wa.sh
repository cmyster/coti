pre_uc_install_wa ()
{
    # Workarounds needed prior undercloud install.

    HOST=$1

    # Workarounds that are needed to be run inside a node go in this script:
    echo "Running pre-undercloud install workarounds."
    cat > pre_uc_install_wa <<EOF
### Workrounds go here
# This is to avoid some dependancy hell.
for pack in "iptables" "subscription-manager" "bigswitch"
do
    if rpm -qa | grep \$pack
    then
        rpm -qa | grep \$pack | xargs sudo rpm -e --nodeps
    fi
done
sudo yum install -y subscription-manager iptables
### End of workarounds
EOF

    run_script_file pre_uc_install_wa stack "$HOST" /home/stack

    # Workarounds that work from outside the nodes go here:
}
