install_extra_packages ()
{
    if [[ "$(echo $GUEST_FILE | rev | cut -d "-" -f 1 | awk -F. '{print $NF}' | rev)" == "latest" ]]
    then
        echo "Discovering the exact version of \"latest\"."
        GUEST_ACTUAL="$(sshpass -p${UPLOAD_PASS} $SSH_CUST ${UPLOAD_USER}@${SRV_DOMAIN} "readlink $GUEST_BASE_PATH/$GUEST_FILE" | awk -F/ '{print $NF}' | tr -d '\r')"
        echo "$GUEST_ACTUAL will be used."
        echo $GUEST_ACTUAL > guest_image
    else
        GUEST_ACTUAL="$GUEST_FILE"
        echo $GUEST_ACTUAL > guest_image
    fi

    download_from_epel ()
    {
        if ! /bin/ls "${1}"*rpm &> /dev/null
        then
            echo "Downloading $1"
            cd /tmp
            try wget -q -nv -r -nd -np "${EPEL}"/"${1:0:1}"/ -A "${1}*rpm" || failure
            cd $WORK_DIR
        fi
    }

    install_if_not ()
    {
        if ! rpm -qa | grep "$1" &> /dev/null
        then
            echo "Installing $1"
            pkg=$(/bin/ls -1 "${1}"*)
            rpm -Uvh "$pkg"
        fi
    }

    # I rather re-download. The package is small and I need latest.
    if ! /bin/ls rhos-release-latest.noarch.rpm &> /dev/null
    then
        try wget -q -nv "$LATEST_RR" || failure
    fi

    if ! /bin/ls $GUEST_ACTUAL &> /dev/null
    then
        if ! /bin/ls /tmp/$GUEST_ACTUAL &> /dev/null
        then
            cd /tmp
            echo "Downloading $GUEST_ACTUAL"
            try wget -nv "$FILE_SERVER/$GUEST_BASE_LINK/$GUEST_ACTUAL" || failure
            cd $WORK_DIR
        fi
        cp /tmp/$GUEST_ACTUAL .
    fi
    
    for package in "nethogs" "htop" "sshpass"
    do
        if ! /bin/ls /tmp/${package}* &> /dev/null
        then
            download_from_epel $package
            install_if_not $package
        fi 
        cp /tmp/${package}*rpm .
    done

    echo "Tarring needed files."
    tar cf files.tar ./*.rpm ./*.conf &> /dev/null
}
