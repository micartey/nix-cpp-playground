project('pistache-webserver', 'cpp',
  version: '1.0.0',
  default_options: [
    'cpp_std=c++20',
    'buildtype=release',
    'warning_level=3'
  ]
)

add_project_arguments('-Wall', language: 'cpp')
add_project_arguments('-Wextra', language: 'cpp')

pistache_dep = dependency('libpistache', required: true)
openssl_dep = dependency('openssl', required: true)

inc = include_directories('include')

sources = run_command('find', 'src', '-name', '*.cpp', check: true).stdout().strip().split('\n')

executable('main',
  sources,
  include_directories: inc,
  dependencies: [pistache_dep, openssl_dep],
  install: true
)
