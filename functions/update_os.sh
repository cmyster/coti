update_os ()
{
    try yum -q -y update || failure
}
