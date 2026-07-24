# Define new channel for logging
#
# @param file_path
#   The path to the log file
#
# @param file_size
#   The maximum size the log file is allowed to reach
#
# @param file_versions
#   The number of log files to keep when rotating
#
# @param log_type
#   The destination type for the log (file, stderr, syslog, or "null")
#
# @param order
#   The order of the channel in the configuration file
#
# @param print_category
#   Decide whether to log the category in the log message
#
# @param print_severity
#   Decide whether to log the severity in the log message
#
# @param print_time
#   Decide whether to log the time in the log message
#
# @param severity
#   The severity of messages to log
#
# @param syslog_facility
#   The syslog facility to use when logging to a syslog log_type
define dns::logging::channel (
  Optional[Stdlib::Absolutepath] $file_path                   = undef,
  Optional[String] $file_size                                 = undef,
  Optional[Variant[Enum['unlimited'],Integer]] $file_versions = undef,
  Enum['file', 'null', 'stderr', 'syslog'] $log_type          = undef,
  Integer[51, 59] $order                                      = 51,
  Optional[Enum['no', 'yes']] $print_category                 = undef,
  Optional[Enum['no', 'yes']] $print_severity                 = undef,
  Optional[Enum['no', 'yes']] $print_time                     = undef,
  Optional[String] $severity                                  = undef,
  Optional[String] $syslog_facility                           = undef,
) {
  include dns::logging

  $channel_name = $title

  if $log_type == 'syslog' {
    if empty($syslog_facility) {
      fail('dns::logging::channel: "syslog_facility" needs to be set with log type syslog')
    }
  }

  if $log_type == 'file' {
    if empty($file_path) {
      fail('dns::logging::channel: "file_path" needs to be set with log type file')
    }
    if $file_versions and empty($file_size) {
      fail('dns::logging::channel: "file_size" needs to be set if "file_version" is set')
    }
  }

  concat::fragment { "named.conf-logging-channel-${title}.dns":
    target  => $dns::namedconf_path,
    content => template('dns/log.channel.conf.erb'),
    order   => $order,
  }
}
