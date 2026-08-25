-----------------------------------------------------------------
-- String methods.
-----------------------------------------------------------------
local M = {}

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local unpack = table.unpack
local concat = table.concat
local insert = table.insert

-----------------------------------------------------------------
-- Implementation.
-----------------------------------------------------------------
function M.words( str )
  assert( type( str ) == 'string',
          'expected type string but found type ' .. type( str ) )
  local trimmed = M.trim( str )
  if #trimmed == 0 then return {} end
  return M.split( M.trim( str ), '%s+' )
end

function M.unwords( lst )
  assert( type( lst ) == 'table',
          'expected type table but found type ' .. type( lst ) )
  local sanitized = {}
  for _, s in ipairs( lst ) do
    local trimmed = M.trim( s )
    if #trimmed > 0 then insert( sanitized, trimmed ) end
  end
  return concat( sanitized, ' ' )
end

function M.trim( str )
  -- The '-' is like '*' except it matches the shortest sequence
  -- instead of the longest sequence.
  return str:match( '^%s*(.-)%s*$' )
end

function M.trim_right( str )
  -- The '-' is like '*' except it matches the shortest sequence
  -- instead of the longest sequence.
  return str:match( '^(.-)%s*$' )
end

-- Set plain=true to suppress pattern matching in `sep` and just
-- use its contents literally.
function M.split( str, sep, plain )
  if plain == nil then plain = false end
  assert( type( str ) == 'string' )
  sep = sep or ' '
  local res = {}
  while true do
    local i, j = str:find( sep, 1, plain )
    if not i then
      insert( res, str )
      break
    end
    local frag = str:sub( 1, i - 1 )
    insert( res, frag )
    str = str:sub( j + 1 )
  end
  return res
end

-- Split but return the results as a tuple:
--   E.g. local k, v = tsplit( 'hello=world', '=' )
function M.tsplit( str, sep )
  return unpack( M.split( str, sep ) ) --
end

function M.tsplit_trim( str, sep, opts )
  return unpack( M.split_trim( str, sep, opts ) ) --
end

function M.split_trim( str, sep, opts )
  opts = opts or {}
  opts.remove_empty = opts.remove_empty or false
  local untrimmed = M.split( str, sep )
  local trimmed = {}
  for _, e in ipairs( untrimmed ) do
    local s = M.trim( e )
    if #s == 0 and opts.remove_empty then goto continue end
    insert( trimmed, M.trim( e ) )
    ::continue::
  end
  return trimmed
end

function M.enable_string_injections()
  if not string.split then string.split = M.split end
  if not string.tsplit then string.tsplit = M.tsplit end
  if not string.trim then string.trim = M.trim end
  if not string.words then string.words = M.words end
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return M
