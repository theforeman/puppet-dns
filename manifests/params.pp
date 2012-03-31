class dns::params {
    $dnsdir             = "/etc/bind"
    $namedconf_path     = "${dnsdir}/named.conf"
    $vardir             = "/var/cache/bind"
    $optionspath        = "${dnsdir}/named.conf.options"
    $dns_server_package = "bind9"
    $namedservicename   = "bind9"
    $user               = 'bind'

    #pertaining to rndc
    $rndckeypath = "${dnsdir}/rndc.key"

    #pertaining to views
    $publicviewpath   = "${dnsdir}/zones.conf"
    $publicview       = "zones"
    $zonefilepath     = "${vardir}/zones"
}
