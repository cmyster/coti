run_heat_tests ()
{
    HOST=$1    
    cp $CWD/functions/run_heat_tests .
    run_script_file run_heat_tests root $HOST /root/
    try scp -q root@${HOST}:/root/*heat_integrationtests.xml . || failure
}
