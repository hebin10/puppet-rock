#
# Class that configures mysql for rock
#
# 1. Make sure database $dbname exist.
# 2. Create user $username@$hosts. Note there maybe more than one user.
# 3. Grant all privileges on $dbname.* to $username@$hosts.
#

class rock::db::mysql(
  $password,
  $dbname        = 'rock',
  $username      = 'rock',
  $hosts         = ['127.0.0.1','%'],
  $charset       = 'utf8',
) {

  require 'mysql::bindings'
  require 'mysql::bindings::python'

  mysql_database { $dbname:
    charset => $charset,
    ensure  => present,
  }

  unique($hosts)

  rock::db::mysql::host_access { $hosts:
    username => $username,
    password => $password,
    database => $dbname,
  }
}
