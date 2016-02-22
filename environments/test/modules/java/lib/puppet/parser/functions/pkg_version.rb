#!/usr/bin/env ruby
#
module Puppet::Parser::Functions
	newfunction(:jdk_pkg_version, :type => :rvalue) do |args|
		ver = args[0].gsub(/^1\.([789])\.0_(\d+)$/, '\1u\2')
		if ver == args[0] do
			raise Puppet::ParseError, "Can't read java version string $args[0] : expecting format 1.[789].0_\#\#"
		end
		ver
	end
end



