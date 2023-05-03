local _MODREV, _SPECREV = 'scm', '-1'
rockspec_format = '3.0'
package = 'testproject'
version = _MODREV .. _SPECREV

description = {
  summary = 'For testing',
  homepage = 'http://github.com/mrcjkb/' .. package,
  license = 'MIT',
}

dependencies = {
  'lua >= 5.1',
  'plenary.nvim',
}

test_dependencies = {
  'lua >= 5.1',
  'plenary.nvim',
  'busted',
}

source = {
  url = 'git://github.com/mrcjkb/' .. package,
}

build = {
  type = 'builtin',
}
