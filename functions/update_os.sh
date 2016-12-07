update_os ()
{
    try yum -q -y update yum || failure
    try yum -q -y update || failure
}
