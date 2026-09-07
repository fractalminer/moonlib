The build in this folder is designed so that each source file
in the src/ folder will be separately compiled and linked into
its own shared object and installed, i.e. it will be its own
lua module.  For example, src/foo.cpp will end up as:

  local foo = require( 'moon.foo' )

when installed.