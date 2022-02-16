# Validate dnssec-policy parameter
type Dns::Dnssec_policy_key = Struct[
  {
    type      => Enum['csk', 'ksk', 'zsk'],
    directory => Optional[Enum['key-directory']],
    lifetime  => String[1],
    algorithm => Variant[String[1], Integer],
    size      => Optional[Integer],
  }
]
