overcloud_wait ()
{
    HOST=$1
    echo "Waiting for the overcloud to finish."
    STACK=overcloud
    cat > wait <<EOF
#!/bin/bash
cd /home/stack
source stackrc
while ps -ef | grep -v grep | grep "openstack overcloud deploy"
do
    sleep 30
done
RESPONSE=\$(openstack stack list -f value -c 'Stack Name' -c 'Stack Status' | grep $STACK | cut -d " " -f 2)
if [[ "\$RESPONSE" != "CREATE_COMPLETE" ]]
then
    exit 1
fi

EOF
    run_script_file wait root "$HOST" /root
}
