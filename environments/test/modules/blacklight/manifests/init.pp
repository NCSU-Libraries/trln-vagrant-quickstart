class blacklight {
	
	include 'chruby'
	include 'gitsetup'

        #$blacklightgems = ['bundler', 'blacklight','jettywrapper','traject']
        $project_dir = "/home/vagrant/projects"
        $project_name = "trln-blacklight-quickstart"
	$install_dir = "${project_dir}/${project_name}"

	$git_repo = "https://github.com/NCSU-Libraries/trln-blacklight-quickstart.git"

	package { [ "java-1.8.0-openjdk", "java-1.8.0-openjdk-devel"]:
			ensure => "installed"
	}

	file {
		$project_dir:
			ensure => directory,
			owner => 'vagrant',
			group => 'vagrant'
	}

	exec { "git clone ${git_repo}":
			path => "/usr/local/bin:/usr/bin",
			cwd => $project_dir,	
			user => "vagrant",
			environment => ["HOME=/home/vagrant"],
			creates => $install_dir
	}
	
	file { "/home/vagrant/README":
		ensure => "present",
		source => "puppet:///modules/blacklight/README",
	}

	file { "/home/vagrant/setup.sh":
		ensure=> "present",
		mode => "0755",
		content => "#!/bin/sh\n\necho 'chruby ruby' >> ~/.bashrc"
	}

	service { "firewalld":
		enable => true,
		ensure => "running",
	}

	exec { "open port 8983 (solr)":
		command => "firewall-cmd --add-port=8983/tcp --zone=public --permanent",
		path => [ "/usr/bin" ],
		notify => Service['firewalld'],
	}

	exec { "open port 3000 (rails)":
		command => "firewall-cmd --add-port=3000/tcp --zone=public --permanent",
		path => [ "/usr/bin", "/sbin" ],
		notify => Service['firewalld'],
	}

			
	exec { "Initialize quickstart application":
		command => "$install_dir/init.sh",
		cwd => $install_dir,
		user => "vagrant",
		environment => ["HOME=/home/vagrant"],
		creates => "${install_dir}/solr-install",
		provider => "shell",
	}
		
}

