time_diff ()
{
    # return time delta in HH:mm:ss
    H=$(( $1 / 3600 ))
    M=$(( $1 % 3600 / 60 ))
    S=$(( $1 % 60 ))
    if [ ${#H} -eq 1 ]; then export H="0${H}"; fi
    if [ ${#M} -eq 1 ]; then export M="0${M}"; fi
    if [ ${#S} -eq 1 ]; then export S="0${S}"; fi
    echo "${H}:${M}:${S}"
}
