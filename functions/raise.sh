raise ()
{
    echo "$1 failed" | tee -a "$LOG_FILE"
    echo Failed after "$(time_diff $(( $(date +%s) - START )))" | tee -a "$LOG_FILE"
    exit 1
}
