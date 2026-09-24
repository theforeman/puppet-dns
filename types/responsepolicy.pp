type Dns::ResponsePolicy = Array[
  Struct[{
    zone           => Stdlib::Fqdn,
    policy         => Optional[Enum[
      'given', 'disabled', 'passthru', 'drop',
      'nxdomain', 'nodata', 'tcp-only', 'cname'
    ]],
    cname_domain   => Optional[Stdlib::Fqdn],
    max_policy_ttl => Optional[Integer[0]],
    log            => Optional[Boolean]
  }], 1, 32
]
