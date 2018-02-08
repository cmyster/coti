define_vm ()
{
    if [ ! -r "${1}".xml ]
    then
        echo "The file ${1}.xml was not found."
        raise "${FUNCNAME[0]}"
    fi
    try virsh define "${1}".xml || failure
}
