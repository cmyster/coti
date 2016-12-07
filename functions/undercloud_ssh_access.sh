undercloud_ssh_access ()
{
    # $1 = The hostname. I'm guessing here its resolvable.
    # $2 = The username.
    # $3 = The user's password.
    UNDER_HOST_NAME=$1
    echo "granting $2 a passwordless ssh acceess to $UNDER_HOST_NAME"
    try sshpass -p $3 ssh-copy-id -i /root/.ssh/id_rsa.pub ${2}@$UNDER_HOST_NAME || failure
}
