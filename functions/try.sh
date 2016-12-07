try ()
{
    rm -rf /tmp/tmpcmd /tmp/tmpcmd-err
    echo $@ &> /tmp/tmpcmd
    $@ 2> /tmp/tmpcmd-err
    return $?
}
