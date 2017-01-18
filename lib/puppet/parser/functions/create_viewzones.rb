# helper routine for dns::zone with views feature
# this should be reimplemented with lambdas inside the manifest
# as soon as puppet-dns drops support for older puppet versions
module Puppet::Parser::Functions
  newfunction(:create_viewzones) do |args|

    views = args[0]

    publicviewpath = lookupvar('::dns::publicviewpath')
    viewconfigpath = lookupvar('::dns::viewconfigpath')
    zone  = lookupvar('_zone')
    title = lookupvar('title')

    views.each do |view|

      target = (view == '_GLOBAL_') ? publicviewpath : "#{viewconfigpath}/#{view}.conf"

      function_create_resources([ 'concat::fragment', { "dns_zones+10_#{view}_#{title}.dns" => {
         'target'  => target,
         'content' => function_template(['dns/named.zone.erb']),
         'order'   => "#{view}-11-#{zone}-1",
      }}])

      if view != '_GLOBAL_' then
        function_create_resources([ 'dns::does_view_exist', { "#{view}+#{title}" => { 'view' => view  }}])
      end

    end

  end
end
