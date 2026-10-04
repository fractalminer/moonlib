-----------------------------------------------------------------
-- Global freezing.
-----------------------------------------------------------------
local M = {}

-----------------------------------------------------------------
-- Implementation.
-----------------------------------------------------------------
function M.globals( env )
  return setmetatable( {}, {
    __index=env,
    __newindex=function() error( 'cannot set globals.', 2 ) end,
  } )
end

-- This will do the following on the table:
--
--   1. Prevent reading non-existent fields (though this one can
--      be turned off via options, in which case an invalid field
--      just yields nil).
--   2. Prevent adding new fields.
--   3. Prevent modifying existing fields.
--   4. Apply these same rules recursively.
--
-- Return value: new table that is hardened. The input table is
-- not changed.
function M.harden( tbl, options )
  options = options or {}
  -- Capture any options that we need to save in functions, since
  -- we don't want to hang onto the options table itself just in
  -- case that gets mutated.
  local harden_reads = options.harden_reads or true
  local frozen = {}
  for k, v in pairs( tbl ) do
    assert( k ~= '_G' )
    if type( v ) == 'table' then
      frozen[k] = M.harden( v, options )
    else
      frozen[k] = v
    end
  end
  -- Try to preserve any existing metamethods (e.g. __tostring)
  -- that we won't be overriding.
  local mt = getmetatable( tbl )
  if mt == false then
    error( 'metatable is hidden; cannot harden table' )
  end
  mt = mt or {}
  mt.__index = function( _, k )
    local v = frozen[k]
    if type( k ) == 'number' and math.type( k ) == 'integer' then
      -- We cannot harded non-existent indices because in Lua
      -- 5.4+, the __ipairs metamethod has been removed and in-
      -- stead it uses the __index method. So that means when we
      -- iterate over a hardened list with ipairs it will keep
      -- calling __index with successive integers until it en-
      -- counters nil, thus we cannot throw on an invalid key be-
      -- cause then we wouldn't be able to iterate. We could only
      -- avoid throwing on the integer that is one past the end,
      -- but then that is inconsistent.
      return v
    end
    if harden_reads and v == nil then
      error(
          'attempt to read non-existent key: ' .. tostring( k ),
          2 )
    end
    return v
  end
  mt.__len = function( _ ) return #frozen end
  mt.__pairs = function( _ ) return pairs( frozen ) end
  --[[ NOTE: __ipairs removed in 5.4, uses __index method. ]]
  mt.__newindex = function( _, _, _ )
    error( 'attempt to modify a read-only table.', 2 )
  end
  mt.__metatable = false
  return setmetatable( {}, mt )
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return M
