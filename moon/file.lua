-----------------------------------------------------------------
-- File methods.
-----------------------------------------------------------------
local M = {}

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local cmd = require'moon.cmd'
local str = require'moon.str'
local posix = require'posix'
local stat = require'posix.sys.stat'

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local insert = table.insert
local format = string.format
local command = cmd.command
local trim = str.trim

-----------------------------------------------------------------
-- Implementation.
-----------------------------------------------------------------
function M.exists( name )
  -- TODO: use <close> here.
  local f = io.open( name, 'r' )
  return f ~= nil and f:close()
end

function M.is_symlink( path )
  local s = posix.lstat( path )
  if not s then return false end
  return stat.S_ISLNK( s.st_mode ) ~= 0
end

function M.read_file( name )
  local f<close> = assert( io.open( name, 'r' ) )
  return f:read( 'a' )
end

function M.write_file( name, body )
  local f<close> = assert( io.open( name, 'w' ) )
  return f:write( body )
end

-- The lines do NOT contain newlines at the end.
function M.read_file_lines( name )
  local f<close> = assert( io.open( name, 'r' ) )
  local res = {}
  for line in f:lines() do insert( res, line ) end
  return res
end

M.read_lines = M.read_file_lines

function M.append_string_to_file( filename, what )
  -- TODO: use <close> here.
  local f = assert( io.open( filename, 'a+' ) )
  f:write( what )
  f:close()
end

function M.copy_file( src, dst, options )
  options = options or {}
  options.force = options.force or false
  if not options.force and M.exists( dst ) then
    error( format( 'cannot overwrite file %s', dst ) )
  end
  do
    local infile<close> = assert( io.open( src, 'rb' ) )
    local outfile<close> = assert( io.open( dst, 'wb' ) )
    outfile:write( infile:read( '*a' ) )
  end
end

function M.realpath( p ) return trim( command( 'realpath', p ) ) end

function M.chmod( file, symbolic )
  assert( file )
  assert( symbolic )
  -- chmod returns the error message as second parameter, so
  -- will get reported by the assert if it fires.
  assert( posix.chmod( file, symbolic ) )
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return M
