overcloud_wait ()
{
    HOST=$1
    echo "Waiting for the overcloud to finish."
    STACK=overcloud
    cat > wait <<EOF
#!/bin/bash
source stackrc
INIT_TIMER=500
MASTER_TIMER=20000
SECONDS=0

timeout ()
{
    if [ \$SECONDS -gt \$1 ]
    then
        echo "Timeout was reached."
        echo "Script will now exit."
        echo "Deployment might still be running though."
        exit 1
    fi
}

my_exe ()
{
    /bin/mysql -sN -e "select \$1 from heat.stack where heat.stack.name=\"\$2\";"
}

ACTION=""
while [ -z \$ACTION ]
do
    timeout \$INIT_TIMER
    ACTION=\$(my_exe action $STACK)
    echo "[\$(date +%T)] stack: $STACK, ACTION=\$ACTION, STATUS=\$STATUS"
    sleep 30
done

SECONDS=0

STATUS=\$(my_exe status $STACK)
while [[ "\$STATUS" == "IN_PROGRESS" ]]
do
    timeout \$MASTER_TIMER
    ACTION=\$(my_exe action overcloud)
    STATUS=\$(my_exe status overcloud)
    echo "[\$(date +%T)] stack: $STACK, ACTION=\$ACTION, STATUS=\$STATUS"
    sleep 30
done

ACTION=\$(my_exe action $STACK)
STATUS=\$(my_exe status $STACK)
echo final status: \$ACTION \$STATUS
if [[ "\$ACTION" == "CREATE" ]] && [[ "\$STATUS" == "COMPLETE" ]]
then
    exit 0
else
    exit 1
fi
EOF
    run_script_file wait root "$HOST" /root
}
