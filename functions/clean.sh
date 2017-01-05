clean ()
{
    echo "Cleaning leftovers from previous runs."
    rm -rf tmpcmd
    rm -rf $WORK_DIR
    mkdir -p $WORK_DIR
    cd $WORK_DIR
}
