-----------------------------------------------------------------
-- Table methods.
-----------------------------------------------------------------
local M = {}

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local insert = table.insert
local sort = table.sort

-----------------------------------------------------------------
-- Implementation.
-----------------------------------------------------------------
function M.on_ordered_kv( tbl, op )
  local keys = {}
  for k, _ in pairs( tbl ) do insert( keys, k ) end
  sort( keys )
  for _, k in ipairs( keys ) do
    local v = tbl[k]
    assert( v ~= nil, 'v is nil for k=' .. tostring( k ) ) -- v could be `false`.
    op( k, v )
  end
end

function M.count_keys( tbl )
  assert( type( tbl ) == 'table' )
  local total = 0
  for _, _ in pairs( tbl ) do total = total + 1 end
  return total
end

-- Actually supports any type; if it is not a table it will just
-- get returned since only tables are mutable.
function M.deep_copy( thing )
  if type( thing ) ~= 'table' then return thing end
  local res = {}
  for k, v in pairs( thing ) do
    res[M.deep_copy( k )] = M.deep_copy( v )
  end
  return res
end

local function tables_equal_impl( l, r )
  for k, v in pairs( l ) do
    local equal
    if type( v ) == 'table' and type( r[k] ) == 'table' then
      local ok, kk, l_v, r_v = M.tables_equal( r[k], v )
      if not ok then return ok, kk, l_v, r_v end
      equal = true
    else
      equal = (r[k] == v)
    end
    if not equal then return false, k, v, r[k] end
  end
  return true
end

-- Recursively compare tables.
function M.tables_equal( l, r )
  local ok, k, l_v, r_v
  ok, k, l_v, r_v = tables_equal_impl( l, r )
  if not ok then return ok, k, l_v, r_v end
  ok, k, l_v, r_v = tables_equal_impl( r, l )
  if not ok then return ok, k, l_v, r_v end
  return true
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return M
