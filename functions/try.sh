try ()
{
    rm -rf tmpcmd tmpcmd-err
    echo "$@" &> tmpcmd
    echo "$@" &>> $LOG_FILE
    "$@" 2> tmpcmd-err
    RETURN=$?
    case $RETURN in
        0) echo "DONE" &>> $LOG_FILE ;;
        *) echo "FAIL" &>> $LOG_FILE ;;
    esac
    return $RETURN
}
