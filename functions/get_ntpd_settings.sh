get_ntpd_settings ()
{
    grep -v "#\|^$" /etc/ntp.conf > ntp.conf
}
