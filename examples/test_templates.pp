class {'rock':
  node_type       => 'master',
  remote_database => false,
  local_db_user   => 'hebin',
  local_db_pass   => '1234qwer',
  local_db_host   => '127.0.0.1',
  local_db_name   => 'hello',
  db_allowed_hosts => ['%'],

  debug                        => true,
  verbose                      => false,
  check_cases_interval         => 600,
  message_report_to            => 'kiki',
  message_report_error_allowed =>  false,
  log_dir                      => '/var/log/rock1',
  rock_mon_log_file            => 'rm.log',
  rock_engine_log_file         => 're.log',
  log_date_format              => '%Y%m%d %H%M%S',

  compute_hosts         => ['server-68', 'server-69'],
  management_network_ip => ['10.0.103.68', '10.0.103.69'],
  tunnel_network_ip     => ['10.10.10.1', '10.10.10.2'],
  storage_network_ip    => ['20.20.20.1', '20.20.20.2'],

  connection                   => 'mysql://rock:1234qwer@10.0.103.51/rock?charset=utf8',

  he_check_times    => 10,
  he_check_interval => 20,

  activemq_server_host => '10.0.103.32',
  activemq_server_port => 61613,
  activemq_destination => 'eventQueue',
  activemq_username    => 'hebin',
  activemq_password    => '1234qwer',

  os_username                  => 'admin',
  os_user_domain_id            => 'default',
  os_password                  => '1q2w3e4r',
  os_auth_url                  => 'http://lb.103.hatest.ustack.in:35357/v3',
  os_project_name              => 'openstack',
  os_project_domain_id         => 'default',
  os_nova_client_version       => '2.1',

  mail_api_endpoint            => 'http://10.0.100.37:8200/v1/publish/publish_email',
  mail_address                 => ['hebin@unitedstack.com'],

  ipmi_ips                     => ['10.0.108.119', '10.0.108.120'],
  ipmi_usernames               => ['root', 'root'],
  ipmi_passwords               => ['PQ79ISF7ha7G', 'PQ79ISF7ha7G'],

  get_nova_service_status_interval    => 600,
  get_ping_result_interval            => 600,
  allowed_number_of_hostdown_togerther => 5,
}
