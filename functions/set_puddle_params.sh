set_puddle_params ()
{
    PUDDLE=$(cat puddle)
    echo "Looking if $PUDDLE has an image package."
    try curl -sL $AUTO_PATH/$OS_VER &> puddles.html || failure
    if grep $PUDDLE puddles.html &> /dev/null
    then
        echo "Current puddle has an image package."
        CREATE_IMAGES=false
    else
        echo "Current puddle image package will be created for later use."
        CREATE_IMAGES=true
    fi
    
    TAR_PATH=${TAR_PATH:-"$AUTO_PATH/$OS_VER/$PUDDLE"}
    echo $TAR_PATH > tar_path
    # Location of the modified guest image.
    MODIFIED_GUEST=${MODIFIED_GUEST:-"$TAR_PATH/guest-image.qcow2"}
    echo $MODIFIED_GUEST > modified_guest
    GUEST_IMAGE=$(basename $MODIFIED_GUEST)
    echo $GUEST_IMAGE > guest_image
}
