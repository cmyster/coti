failure ()
{
    echo "[ $(cat tmpcmd) ] failed" | tee -a $LOG_FILE
    echo "Error output:" | tee -a $LOG_FILE
    cat tmpcmd-err | tee -a $LOG_FILE
    echo Failed after $(time_diff $(( $(date +%s) - $START ))) | tee -a $LOG_FILE
    exit 1
}
