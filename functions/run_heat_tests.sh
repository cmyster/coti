run_heat_tests ()
{
    HOST_NAME=$1    
    cp $CWD/functions/run_heat_tests .
    run_script_file run_heat_tests root $HOST_NAME /root/
    scp root@${HOST_NAME}:/root/heat_integrationtests.xml .
}
