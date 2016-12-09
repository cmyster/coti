try ()
{
    rm -rf tmpcmd tmpcmd-err
    echo $@ &> tmpcmd
    $@ 2> tmpcmd-err
    return $?
}
