get_appliance ()
{
    if ! /bin/ls $APPLIANCE &> /dev/null
    then
        if ! /bin/ls /tmp/$APPLIANCE &> /dev/null
        then
            cd /tmp
            try wget -q -nv "$FILE_SERVER/unrelated/files/$APPLIANCE" || failure
            cd $WORK_DIR
        fi
        cp /tmp/$APPLIANCE .
    fi

    cd $WORK_DIR
    echo "Downloading and setting guestfs appliance."

    try tar xf $APPLIANCE || failure
    if [ ! -d appliance ]
    then
        raise "${FUNCNAME[0]}"
    fi
    export LIBGUESTFS_PATH="$WORK_DIR/appliance"
    export LIBGUESTFS_BACKEND="direct"
}
