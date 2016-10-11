class {'rock':
  node_type                    => 'master',
  remote_database              => true,

  message_report_to            => 'activemq',
  message_report_error_allowed => true,

  compute_hosts                => ['server-68', 'server-69'],
  management_network_ip        => ['10.0.103.68', '10.0.103.69'],

  connection                   => 'mysql://rock:1234qwer@10.0.103.51/rock?charset=utf8',

  os_username                  => 'admin',
  os_user_domain_id            => 'default',
  os_password                  => '1q2w3e4r',
  os_auth_url                  => 'http://lb.103.hatest.ustack.in:35357/v3',
  os_project_name              => 'openstack',
  os_project_domain_id         => 'default',
  os_nova_client_version       => '2.0',

  activemq_server_host         => '10.0.103.32',
  activemq_server_port         => 61613,
  activemq_destination         => 'eventQueue',

  ipmi_ips                     => ['10.0.108.119', '10.0.108.120'],
  ipmi_usernames               => ['root', 'root'],
  ipmi_passwords               => ['PQ79ISF7ha7G', 'PQ79ISF7ha7G'],
}
