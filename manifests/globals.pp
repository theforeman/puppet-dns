# @summary global default settings for the module that also can
#
# @param $scl Enable the usage of SCL (see readme) when considering paths etc.
#
class dns::globals (
  Optional[Pattern[/^[a-z]+-[a-z]+$/]] $scl  = undef
) {}
