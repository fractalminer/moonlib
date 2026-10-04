-----------------------------------------------------------------
-- Tests for the set module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require( 'moon.unit.assertion' )
local subprocess = require( 'moon.subprocess' )
local file = require( 'moon.file' )
local str = require( 'moon.str' )

str.enable_string_injections()

-----------------------------------------------------------------
-- Freeze global access.
-----------------------------------------------------------------
-- Declare all globals used.
local assert = assert
local os = os

local format = assert( string.format )

-- No reading or writing of globals from here on.
local _ENV = nil

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local ASSERT = assert( assertion.ASSERT )
local ASSERT_EQ = assert( assertion.ASSERT_EQ )
local ASSERT_MATCH = assert( assertion.ASSERT_MATCH )

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.execute()
  local fname = '/tmp/subprocess-test'

  if file.exists( fname ) then os.remove( fname ) end

  ASSERT( not file.exists( fname ) )
  subprocess.execute( 'touch', { fname } )
  ASSERT( file.exists( fname ) )
end

function Test.popen_success()
  local path = 'ls'
  local home = assert( os.getenv( 'HOME' ) )
  local args = { '-l', format( '%s/dev/moonlib', home ) }
  local opts = {
    use_path_env=true, --
    poll_timeout_millis=-1, --
    on_poll=nil, --
    cwd=nil, --
  }
  local res = subprocess.popen( path, args, opts )
  ASSERT_EQ( res.status, 0 )
  ASSERT_EQ( res.stderr, '' )
  ASSERT_EQ( res.reason, 'exited' )
  ASSERT_MATCH( res.stdout, 'LICENSE' )
  ASSERT_MATCH( res.stdout, 'README.md' )
end

function Test.popen_fail()
  local path = 'ls'
  local home = assert( os.getenv( 'HOME' ) )
  local args = { '-l', format( '%s/dev/moonlibx', home ) }
  local opts = {
    use_path_env=true, --
    poll_timeout_millis=-1, --
    on_poll=nil, --
    cwd=nil, --
  }
  local res = subprocess.popen( path, args, opts )
  ASSERT_EQ( res.status, 2 )
  ASSERT_EQ( res.stdout, '' )
  ASSERT_EQ( res.reason, 'exited' )
  local stderr_expected = format(
                              'ls: cannot access \'%s/dev/moonlibx\': No such file or directory',
                              home )
  ASSERT_EQ( res.stderr:trim(), stderr_expected )
end
