Building
--------
The build in this folder is designed so that each source file in
the src/ folder will be separately compiled and linked into its
own shared object and installed, i.e. it will be its own lua mod-
ule. For example, src/foo.cpp will end up as:

  local foo = require( 'moon.foo' )

when installed.


compile_commands.json
---------------------
Run gen-compile-commands.sh to auto generate the
compile_commands.json.