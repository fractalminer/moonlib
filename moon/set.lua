-----------------------------------------------------------------
-- Set Type.
-----------------------------------------------------------------
-- Usage:
--
--   local set = require( 'moon.set' )
--
--   s = set()
--   s:add( 'one' )
--   s:add( 'two' )
--   s:add( 'three' )
--   assert( #s == 3 )
--   assert( s:size() == 3 )
--   assert( s:contains( 'two' ) )
--   assert( not s:contains( 'xxx' ) )
--
--   s = set{ 'one', 'two', 'three' }
--   assert( s:contains( 'two' ) )
--   assert( #s == 3 )
--   s:del( 'two' )
--   assert( not s:contains( 'two' ) )
--   assert( #s == 2 )
--
--   -- Non-deterministic order.
--   for elem in s do
--     ...
--   end
--
--   -- Deterministic order.
--   for elem in s:sorted() do
--     ...
--   end
--
local M = {}
-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local list = require( 'moon.list' )

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local listify = assert( list.listify )

local concat = assert( table.concat )
local insert = assert( table.insert )
local sort = assert( table.sort )

-----------------------------------------------------------------
-- Set type.
-----------------------------------------------------------------
function M.set( lst )
  lst = lst or {}

  local size = 0
  local contents = {}
  local methods = {}

  local o = {}

  function methods.add( self, elem )
    assert( self == o, 'set called with incorrect self object' )
    assert( elem, 'cannot insert nil into a set' )
    if not contents[elem] then size = size + 1 end
    contents[elem] = true
  end

  function methods.del( self, elem )
    assert( self == o, 'set called with incorrect self object' )
    assert( elem, 'cannot remove nil into a set' )
    if contents[elem] then size = size - 1 end
    assert( size >= 0 )
    contents[elem] = nil
  end

  function methods.contains( self, elem )
    assert( self == o, 'set called with incorrect self object' )
    assert( elem, 'cannot contain nil in a set' )
    return contents[elem] ~= nil
  end

  function methods.size( self )
    assert( self == o, 'set called with incorrect self object' )
    return size
  end

  function methods.empty( self )
    assert( self == o, 'set called with incorrect self object' )
    return size == 0
  end

  function methods.clone( self )
    assert( self == o, 'set called with incorrect self object' )
    return M.set( self:list() )
  end

  -- Non-deterministic order.
  function methods.list( self )
    assert( self == o, 'set called with incorrect self object' )
    return listify( self )
  end

  -- Returns a sorted list.
  function methods.sorted( self )
    assert( self == o, 'set called with incorrect self object' )
    local l = self:list()
    sort( l )
    return l
  end

  function methods.clear( self )
    assert( self == o, 'set called with incorrect self object' )
    contents = {}
    size = 0
  end

  function methods.subtract( self, other )
    assert( self == o, 'set called with incorrect self object' )
    if self == other then
      self:clear()
      return
    end
    for e in other do self:del( e ) end
  end

  function methods.diff( self, other )
    assert( self == o, 'set called with incorrect self object' )
    local copy = self:clone()
    copy:subtract( other )
    return copy
  end

  function methods.tostring( self )
    assert( self == o, 'set called with incorrect self object' )
    local cs = { '{' }
    local comma = ''
    for _, e in ipairs( self:sorted() ) do
      insert( cs, comma )
      insert( cs, tostring( e ) )
      comma = ','
    end
    insert( cs, '}' )
    return concat( cs )
  end

  local mt = {
    __index=methods,
    __newindex=function()
      error( 'cannot set members of a set', 2 )
    end,
    __len=function() return size end,
    -- NOTE: __ipairs removed in 5.4; the ipairs method now uses
    -- the __index method. Because of that, we can't prevent the
    -- user from using ipairs, which would be ideal because
    -- ipairs won't work on the set because it doesn't have nu-
    -- merical keys or an ordering.
    __pairs=function()
      error( 'a set does not have pairs: use items()', 2 )
    end,
    -- This allows: for e in s do ... end
    __call=function( _, _, key ) return next( contents, key ) end,
    __sub=methods.diff,
    __tostring=methods.tostring,
  }

  local res = setmetatable( o, mt )

  for _, elem in ipairs( lst ) do res:add( elem ) end

  return res
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return M.set
