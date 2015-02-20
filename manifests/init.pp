class winapache {

  file { 'c:\apache_2.4.4-x64-openssl-1.0.1e.msi':
    ensure => file,
    source => 'puppet:///modules/winapache/apache_2.4.4-x64-openssl-1.0.1e.msi',
    before => Package['Apache HTTP Server 2.4.4'],
  }

  package { "Apache HTTP Server 2.4.4":
    ensure          => present,
    source          => 'c:\apache_2.4.4-x64-openssl-1.0.1e.msi',
    install_options => [
      'AgreeToLicense=Yes',
      'SERVERADMIN=cbarker@puppetlabs.com',
      "SERVERDOMAIN=server2012r2a",
      "SERVERNAME=server2012r2a",
      "SERVERPORT=${::ipaddress}:80",
      'SetupType=Typical',
    ],
  }

  file_line { 'update_servername':
    ensure  => present,
    line    => "ServerName ${::ipaddress}:80",
    path    => 'c:/Program Files/Apache Software Foundation/Apache2.4/conf/httpd.conf',
    require => Package['Apache HTTP Server 2.4.4'],
  }

  exec { 'enable_port_80':
    command     => 'New-NetFirewallRule -DisplayName "Allow Port 80" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow',
    refreshonly => true,
    provider    => powershell,
    subscribe   => Package['Apache HTTP Server 2.4.4'],
  }

  exec { 'install_httpd_service':
    command     => 'httpd.exe -k install',
    path        => 'C:\Program Files\Apache Software Foundation\Apache2.4\bin',
    refreshonly => true,
    subscribe   => Package['Apache HTTP Server 2.4.4'],
  }

  service { 'Apache2.4':
    ensure    => running,
    enable    => true,
    subscribe => File_line['update_servername'],
    require   => Exec['enable_port_80','install_httpd_service'],
  }
}
