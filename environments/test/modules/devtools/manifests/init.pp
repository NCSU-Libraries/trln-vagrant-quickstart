# Class: devtools
# ===========================
#
# Installs necessary tools for basic development on server (e.g. c/c++ compilers, git)
#
# Parameters
# ----------
#
# None yet.
#
# Variables
# ----------
# None yet.
#
# Authors
# -------
#
# Author Name <adam_constabaris@ncsu.edu>
#
# Copyright
# ---------
#
# Copyright 2016 North Carolina State University
#
class devtools {

	$tools = [ "lsof", "vim-enhanced", "nano" ]

	$headers = [ "glibc-devel", "libxml2-devel", "sqlite-devel" ]

	$compilers = [ "gcc", "gcc-c++" ]

	package { $tools:
 			ensure => "installed"
	}

	package { $headers:
			ensure => "installed"
	}

	package { $compilers:
			ensure => "installed"
	}

}
