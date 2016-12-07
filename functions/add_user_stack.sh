add_user_stack ()
{
    # if missing, add the stack user and give it sudo rights
    grep ^stack /etc/passwd &> /dev/null
    if [ $? -ne 0 ]
    then
        echo "user stack not found"
        useradd stack
        echo stack | passwd stack --stdin
        rm -rf /etc/sudoers.d/stack
        echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
        chmod 0440 /etc/sudoers.d/stack
    fi
}
