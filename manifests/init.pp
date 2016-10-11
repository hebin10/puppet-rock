# Class: rock
# ===========================
#
# Full description of class rock here.
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
#    class { 'rock':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class rock (
  $node_type                      = 'master',
  $remote_database                = true,
  $local_db_user                  = 'rock',
  $local_db_pass                  = undef,
  $local_db_host                  = '127.0.0.1',
  $local_db_name                  = 'rock',
  $db_allowed_hosts               = ['127.0.0.1', '%'],

  ## For rock.ini

  # [DEFAULT]
  $debug                          = false,
  $verbose                        = true,
  $check_cases_interval           = 300,
  $message_report_to              = 'kiki',
  $message_report_error_allowed   = true,
  $log_dir                        = '/var/log/rock',
  $rock_mon_log_file              = 'rock-mon.log',
  $rock_engine_log_file           = 'rock-engine.log',
  $log_date_format                = '%Y-%m-%d %H:%M:%S',

  # [host_mgmt_ping]
  $compute_hosts                  = [],
  $management_network_ip          = [],
  $tunnel_network_ip              = [],
  $storage_network_ip             = [],

  # [database]
  $connection                     = undef,

  # [openstack_credential]
  $os_username                    = 'admin',
  $os_user_domain_id              = 'default',
  $os_password                    = '1q2w3e4r',
  $os_auth_url                    = 'http://lb.103.hatest.ustack.in:35357/v3',
  $os_project_name                = 'openstack',
  $os_project_domain_id           = 'default',
  $os_nova_client_version         = '2.0',

  # [host_evacuate]
  $he_check_times                 = 6,
  $he_check_interval              = 15,

  # [activemq]
  $activemq_server_host           = 'localhost',
  $activemq_server_port           = 61613,
  $activemq_destination           = 'eventQueue',
  $activemq_username              = undef,
  $activemq_password              = undef,

  # [kiki]
  $mail_api_endpoint              = undef,
  $mail_address                   = [],

  ## For target.json, used by ipmi
  $ipmi_ips                       = [],
  $ipmi_usernames                 = [],
  $ipmi_passwords                 = [],

  ## For alembic.ini
  $alembic_script_location        = '/usr/lib/python2.7/site-packages/rock/db/sqlalchemy/alembic',

  ## For cases/host_down.json
  $get_nova_service_status_interval     = 300,
  $get_ping_result_interval             = 300,
  $allowed_number_of_hostdown_togerther = 2,
){
  # Check input
  if !is_array($compute_hosts) or !is_array($management_network_ip) or !is_array($tunnel_network_ip)
    or !is_array($storage_network_ip) or !is_array($ipmi_ips) or !is_array($ipmi_usernames)
    or !is_array($ipmi_passwords){
    fail("params: 'compute_hosts', 'management_network_ip', 'tunnel_network_ip', 'storage_network_ip', 'ipmi_ips', 'ipmi_usernames' and 'ipmi_passwords' must be Array!")
  }

  if size($compute_hosts) < 1 {
    fail("you must provide at least one compute host!")
  }

  if size($compute_hosts) != size($management_network_ip) or
     size($compute_hosts) != size($ipmi_ips) {
      fail("number of compute hosts, management networks and ipmi ips must be the same!")
  }

  if $node_type != 'slave' and $node_type != 'master' {
    fail("param 'node_type' must either be 'master' or 'slave'!")
  }

  if $remote_database and $connection == undef {
    fail('When use remote database, you must provide a database connection string.')
  }
  if !$remote_database and $local_db_pass == undef {
    fail("when use local database, you must specify a local_db_pass.")
  }

  if !$remote_database {
    $real_connection = "mysql://${local_db_user}:${local_db_pass}@${local_db_host}/${local_db_name}"
  } else {
    $real_connection = $connection
  }

  if !$remote_database {
    class {'::rock::db::mysql':
      password => $local_db_pass,
      dbname   => $local_db_name,
      username => $local_db_user,
      hosts    => unique(concat([$local_db_host], $db_allowed_hosts)),
      notify   => Exec['rock-db-upgrade'],
    }
  }

  # Install rock
  package { 'rock':
    ensure => present,
  }

  # Config rock
  file { '/etc/rock/rock.ini':
    ensure  => file,
    require => Package['rock'],
    content => template('rock/etc/rock.ini.erb'),
  }
  file { '/etc/rock/target.json':
    ensure  => file,
    require => Package['rock'],
    content => template('rock/etc/target.json.erb'),
  }
  file{ '/etc/rock/alembic.ini':
    ensure  => file,
    require => Package['rock'],
    content => template('rock/etc/alembic.ini.erb'),
  }
  file { '/etc/rock/cases/host_down.json':
    ensure  => file,
    require => Package['rock'],
    content => template('rock/etc/cases/host_down.json.erb'),
  }


  # Initialize database
  exec { 'rock-db-upgrade':
    command  => '/usr/bin/rock-db-manage upgrade head',
    require  => File['/etc/rock/alembic.ini'],
    subscribe => File['/etc/rock/alembic.ini'],
  }

  # Service rock-mon and rock-engine
  if $node_type == 'slave' {
    service { 'rock-mon':
      enable    => false,
      ensure    => stopped,
    }
    service { 'rock-engine':
      enable => false,
      ensure => stopped,
    }
  } else {
    service { 'rock-mon':
      enable    => true,
      ensure    => running,
      subscribe => [File['/etc/rock/rock.ini'], Exec['rock-db-upgrade']]
    }
    service { 'rock-engine':
      enable     => true,
      ensure     => running,
      subscribe => [File['/etc/rock/rock.ini', '/etc/rock/target.json', '/etc/rock/cases/host_down.json'],
                    Exec['rock-db-upgrade']]
    }
  }
}
