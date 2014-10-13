#
define mcollective::plugin(
  $source = undef,
  $package = false,
  $type = 'agent',
  $has_client = true,
  # $client and $server are to allow for unit testing, and are considered private
  # parameters
  $client = $mcollective::client,
  $server = $mcollective::server,
  $package_ensure = 'present',
) {
  if $package {
    # install from a package named "mcollective-${name}-${type}"
    $package_name = "mcollective-${name}-${type}"
    package { $package_name:
      ensure => $package_ensure,
    }

    if $server {
      # Install after mcollective::server::install and
      # set up a notification if we know we're managing a server
      Class['mcollective::server::install'] ->
      Package[$package_name] ~>
      Class['mcollective::server::service']
    }

    # install the client package if we're installing on a $mcollective::client
    if $client and $has_client {
      package { "mcollective-${name}-client":
        ensure => $package_ensure,
      }

      Class['mcollective::client::install'] ->
      Package["mcollective-${name}-client"]
    }
  }
  else {
    # file sync the module into mcollective::site_libdir
    if $source {
      $source_real = $source
    }
    else {
      $source_real = "puppet:///modules/mcollective/plugins/${name}"
    }

    datacat_fragment { "mcollective::plugin ${name}":
      target => 'mcollective::site_libdir',
      data   => {
        source_path => [ $source_real ],
      },
    }
  }
}
