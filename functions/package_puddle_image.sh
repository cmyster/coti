package_puddle_image ()
{
    PUDDLE=$(cat puddle)
    RR_CMD=$(cat rr_cmd)
    mkdir "$PUDDLE"
    mv "$GUEST_IMAGE" "$PUDDLE"
    echo "built on: $(date)" > "$PUDDLE"/version
    echo "command used: rhos-relese $RR_CMD" >> "$PUDDLE"/version
    echo "puddles used:" >> "$PUDDLE"/version
    tar cf "${PUDDLE}".tar "$PUDDLE"
}
