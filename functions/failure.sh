failure ()
{
    echo "[ $(cat tmpcmd) ] failed" | tee -a "$LOG_FILE"
    echo "Error output:" | tee -a "$LOG_FILE"
    < tmpcmd-err tee -a "$LOG_FILE"
    echo "Please take a look at ${WORK_DIR}/${1}.out"
    echo "Failed after $(time_diff $(( $(date +%s) - START )))" | tee -a "$LOG_FILE"
    exit 1
}
