local _MODREV, _SPECREV = 'scm', '-1'
rockspec_format = '3.0'
package = 'testproject'
version = _MODREV .. _SPECREV

test_dependencies = {
  'lua >= 5.1',
  'plenary.nvim',
  'nlua',
}

source = {
  url = 'git://github.com/mrcjkb/' .. package,
}

build = {
  type = 'builtin',
}
