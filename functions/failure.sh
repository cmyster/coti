failure ()
{
    echo "[ $(cat /tmp/tmpcmd) ] failed" | tee -a $LOG_FILE
    echo "error output:" | tee -a $LOG_FILE
    cat /tmp/tmpcmd-err | tee -a $LOG_FILE
    echo failed after $(time_diff $(( $(date +%s) - $START ))) | tee -a $LOG_FILE
    clean
    exit 1
}
