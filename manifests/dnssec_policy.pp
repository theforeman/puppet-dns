# Manage custom DNSSEC policies
#
# @param dnskey_ttl
#   This indicates the TTL to use when generating DNSKEY resource records.
# @param keys
#   This is a list specifying the algorithms and roles to use when generating
#   keys and signing the zone. Entries in this list do not represent specific
#   DNSSEC keys, which may be changed on a regular basis, but the roles that
#   keys play in the signing policy.
# @param max_zone_ttl
#   This specifies the maximum permissible TTL value in seconds for the zone.
# @param parent_ds_ttl
#   This is the TTL of the DS RRset that the parent zone uses.
# @param parent_propagation_delay
#   This is the expected propagation delay from the time when the parent zone is
#   updated to the time when the new version is served by all of the parent
#   zone’s name servers.
# @param publish_safety
#   This is a margin that is added to the pre-publication interval in rollover
#   timing calculations, to give some extra time to cover unforeseen events.
#   This increases the time between when keys are published and they become
#   active.
# @param retire_safety
#   This is a margin that is added to the post-publication interval in rollover
#   timing calculations, to give some extra time to cover unforeseen events.
#   This increases the time a key remains published after it is no longer
#   active.
# @param signatures_refresh
#   This determines how frequently an RRSIG record needs to be refreshed. The
#   signature is renewed when the time until the expiration time is closer than
#   the specified interval.
# @param signatures_validity
#   This indicates the validity period of an RRSIG record (subject to inception
#   offset and jitter).
# @param signatures_validity_dnskey
#   This is similar to signatures-validity, but for DNSKEY records.
# @param zone_propagation_delay
#   This is the expected propagation delay from the time when a zone is first
#   updated to the time when the new version of the zone is served by all
#   secondary servers.
define dns::dnssec_policy (
  Optional[Integer] $dnskey_ttl                   = undef,
  Array[Dns::Dnssec_policy_key] $keys             = [],
  Optional[Integer] $max_zone_ttl                 = undef,
  Optional[Integer] $parent_ds_ttl                = undef,
  Optional[String[1]] $parent_propagation_delay   = undef,
  Optional[String[1]] $publish_safety             = undef,
  Optional[String[1]] $retire_safety              = undef,
  Optional[String[1]] $signatures_refresh         = undef,
  Optional[String[1]] $signatures_validity        = undef,
  Optional[String[1]] $signatures_validity_dnskey = undef,
  Optional[String[1]] $zone_propagation_delay     = undef,
) {
  if $name == 'none' or $name == 'default' {
    fail("The name \"${name}\" is reserved and cannot be used")
  }

  concat::fragment { "dnssec-policy-${name}":
    target  => $dns::publicviewpath,
    order   => '0',
    content => epp('dns/named.dnssec_policy.epp',
      {
        name    => $name,
        keys    => $keys,
        options => {
          'dnskey-ttl'                 => $dnskey_ttl,
          'max-zone-ttl'               => $max_zone_ttl,
          'parent-ds-ttl'              => $parent_ds_ttl,
          'parent-propagation-delay'   => $parent_propagation_delay,
          'publish-safety'             => $publish_safety,
          'retire-safety'              => $retire_safety,
          'signatures-refresh'         => $signatures_refresh,
          'signatures-validity'        => $signatures_validity,
          'signatures-validity-dnskey' => $signatures_validity_dnskey,
          'zone-propagation-delay'     => $zone_propagation_delay,
        },
      }
    ),
  }
}
