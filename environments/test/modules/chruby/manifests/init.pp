# Class: chruby
# ===========================
#
# Installs chruby (manages multiple Ruby versions)
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'chruby':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Adam Constabaris <ajconsta@ncsu.edu>
#
# Copyright
# ---------
#
# Copyright 2016 North Carolina State University
#
class chruby {
	
	include "devtools"

	$chruby_version = "0.3.9"

	$ruby_install_version = "0.6.0"

	$chruby_archive = "chruby-${chruby_version}.tar.gz"
	
	$ruby_install_archive = "ruby-install-${ruby_install_version}.tar.gz"

	file { "/tmp/${ruby_install_archive}":
		source => "puppet:///modules/chruby/${ruby_install_archive}",
		ensure => "present", 
	}
	
	exec { "extract ruby-install archive":
		command => "tar xzf ${ruby_install_archive}",
		path => [ "/usr/bin" ], 
		cwd => "/tmp",
		user => "vagrant",
		creates => "/tmp/ruby-install-${ruby_install_version}",
	}


	exec { "install ruby-install":
		command => "/usr/bin/make install",
		cwd => "/tmp/ruby-install-${ruby_install_version}",
		creates => '/usr/local/bin/ruby-install'
	}	

	exec { "install ruby 2.3.0":
		command => "ruby-install ruby 2.3.0",
		cwd => "/home/vagrant",
		path => "/usr/local/bin:/usr/bin:/bin:/sbin",
		user => "vagrant", 
		environment => ["HOME=/home/vagrant"],
		creates => "/home/vagrant/.rubies/ruby-2.3.0",
		timeout => 1800
	}


	file { "/tmp/${chruby_archive}":
		source => "puppet:///modules/chruby/${chruby_archive}",
		ensure => "present",

	}

	exec { "extract chruby":
		command => "tar xzf ${chruby_archive}",
		path => [ "/usr/bin" ],
		cwd => "/tmp",
		user => "vagrant",
		creates => "/tmp/chruby-${chruby_version}",
	}
	
	exec { "install chruby":
		command => "setup.sh",
		path => [ "/tmp/chruby-${chruby_version}/scripts", "/usr/local/bin", "/usr/bin" ],
		cwd => "/tmp/chruby-${chruby_version}",
		creates => "/usr/local/bin/chruby-exec",
	}

	exec { "make chruby rubies available":
		command => "echo 'chruby ruby' >> /home/vagrant/.bashrc",
		path => [ "/usr/bin" ],
		user => "vagrant",
		onlyif => "test \"$(grep -c 'chruby ruby' /home/vagrant/.bashrc)\" -eq 0",
	}
	
}
