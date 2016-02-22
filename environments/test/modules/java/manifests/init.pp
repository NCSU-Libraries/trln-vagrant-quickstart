class java {
	$jdkversion = "1.8.0_71"
	$rpm_ver = "8u71"
	$pkg_filename = "jdk-${rpm_ver}-linux-x64.rpm"

	$openjdk = [ "java-1.8.0-openjdk", "java-1.8.0-openjdk-headless" ]


	package { $openjdk:
		ensure => "installed"
	}

	#package { "jdk${jdkversion}":
	#	ensure => 'installed',
	#	provider => 'rpm',
	#	source => "/tmp/${pkg_filename}"
	#}

	#file { "/tmp/${pkg_filename}":
	#	source => "puppet:///modules/java/${pkg_filename}"
	#}
		
}
