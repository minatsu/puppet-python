# Install Pyenv so Python versions can be installed
#
# Usage:
#
#   include python
#
class python(
  $pyenv_root    = $python::params::pyenv_root,
  $pyenv_user    = $python::params::pyenv_user,
  $pyenv_version = $python::params::pyenv_version
) inherits python::params {
  include python::rehash

  if $::osfamily == 'Darwin' {
    include boxen::config

    package { 'readline':
      ensure => latest,
    }

    file { "${boxen::config::envdir}/pyenv.sh":
      source => 'puppet:///modules/python/pyenv.sh',
    }
  }

  repository { $pyenv_root:
    ensure => $pyenv_version,
    source => 'yyuu/pyenv',
    user   => $pyenv_user,
  }

  $venv_root = "${pyenv_root}/plugins/pyenv-virtualenv"
  repository { $venv_root:
    ensure  => 'v20130622',
    source  => 'yyuu/pyenv-virtualenv',
    user    => $pyenv_user,
    require => Repository[$pyenv_root]
  }

  file { "${pyenv_root}/versions":
    ensure  => directory,
    owner   => $pyenv_user,
    require => Repository[$pyenv_root],
  }

  file { "${pyenv_root}/plugins/python-build/bin/pyenv-install":
    ensure  => file,
    source  => 'puppet:///modules/python/pyenv-install',
    owner   => $pyenv_user,
    mode    => '0755',
    require => Repository[$pyenv_root],
  }
}
