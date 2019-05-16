try ()
{
    rm -rf tmpcmd tmpcmd-err
    cat > tmpcmd <<EOF
$@
EOF
    chmod +x tmpcmd
    ./tmpcmd 2> tmpcmd-err
    RETURN=$?
    case $RETURN in
        0) echo "DONE" &>> "$LOG_FILE" ;;
        *) echo "FAIL" &>> "$LOG_FILE" ;;
    esac
    return $RETURN
}
