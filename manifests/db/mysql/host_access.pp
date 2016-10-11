define rock::db::mysql::host_access (
  $username,
  $password,
  $database,
){
  mysql_user { "${username}@${name}":
    ensure        => present,
    password_hash => mysql_password($password),
    require       => Mysql_database[$database],
  }
  mysql_grant { "${username}@${name}/${database}.*":
    privileges => ['ALL'],
    options    => ['GRANT'],
    table      => "${database}.*",
    require    => Mysql_user["${username}@${name}"],
    user       => "${username}@${name}"
  }
}
