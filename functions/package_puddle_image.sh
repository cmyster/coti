package_puddle_image ()
{
    PUDDLE=$(cat puddle)
    RR_CMD=$(cat rr_cmd)
    mkdir "$PUDDLE"
    mv "$GUEST_IMAGE" "$PUDDLE"
    echo "built on: $(date)" > "$PUDDLE"/version
    echo "command used: rhos-release $RR_CMD" >> "$PUDDLE"/version
    tar cf "${PUDDLE}".tar "$PUDDLE"
}
