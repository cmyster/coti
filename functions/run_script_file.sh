run_script_file ()
{
    # Since runnnig the script file is inside a try|failur, no need to run
    # try run_script_file, just call it directly.
    # 1 - file name
    # 2 - username
    # 3 - hostname
    # 4 - run directory
    # example: run_script_file example root undercloud-0 /root/
    chmod +x $1
    try scp -q $1 ${2}@${3}:${4} || failure
    try $SSH ${2}@${3} \""cd ${4} && ./${1} > ${4}/${1}.out 2> ${4}/${1}.err\"" || failure
}
