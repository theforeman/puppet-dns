define dns::rndckey ($alg = "hmac-md5",$secret = "APIEQEbbut1VcDEC/p8PRg==") {
    $keyname = $name
    file {
        "${dns::params::rndckeypath}":
            owner => root,
            group => bind,
            mode => 0640,
            content => template("dns/rndc.key.erb");
    }
}
