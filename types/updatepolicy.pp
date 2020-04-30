# Validate update-policy parameter
type Dns::UpdatePolicy = Variant[
  Enum['local'],
  Hash[
    String,
    Struct[{
      Optional[action] => Enum['deny', 'grant'],
      Optional[tname]  => String,
      rr               => String,
      matchtype        => Enum[
        '6to4-self',
        'external',
        'krb5-self',
        'krb5-selfsub',
        'krb5-subdomain',
        'ms-self',
        'ms-selfsub',
        'ms-subdomain',
        'name',
        'self',
        'selfsub',
        'selfwild',
        'subdomain',
        'tcp-self',
        'wildcard',
        'zonesub',
      ],
    }],
  ],
]
