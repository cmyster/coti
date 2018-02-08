run_script_file ()
{
    # Since runnnig the script file is inside a try|failure, no need to run
    # try run_script_file, just call it directly.
    # 1 - file name
    # 2 - username
    # 3 - hostname
    # 4 - run directory
    # example: run_script_file script_file stack undercloud-0 /home/stack
    chmod +x "$1"
    try scp -q "$1 ${2}@${3}:${4}" || failure
    try "$SSH_CUST" "${2}@${3}" \""${4}/${1}\"" &> "${1}".out || failure "$1"
}
