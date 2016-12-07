set_puddle_params ()
{
    export PUDDLE=$(cat puddle)
    echo "looking if $PUDDLE has an image package"
    try curl -sL $AUTO_PATH/$OSPD_VER &> puddles.html || failure
    if grep $PUDDLE puddles.html &> /dev/null
    then
        echo "current puddle has an image package"
        CREATE_IMAGES=false
    else
        echo "current puddle image package will be created for later use"
        CREATE_IMAGES=true
    fi
    
    export TAR_PATH=${TAR_PATH:-"$AUTO_PATH/$OSPD_VER/$PUDDLE"}
    # location of the modified guest image
    export MODIFIED_GUEST=${MODIFIED_GUEST:-"$TAR_PATH/guest-image.qcow2"}
    export GUEST_IMAGE=$(basename $MODIFIED_GUEST)
}
