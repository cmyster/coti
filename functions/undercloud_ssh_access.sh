undercloud_ssh_access ()
{
    # $1 = The hostname. I'm guessing here its resolvable.
    # $2 = The username.
    # $3 = The user's password.
    HOST_NAME=$1
    echo "granting $2 a passwordless ssh acceess to $HOST_NAME"
    try sshpass -p $3 ssh-copy-id -i /root/.ssh/id_rsa.pub ${2}@$HOST_NAME || failure
}
