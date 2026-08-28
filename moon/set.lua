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
-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local list = require( 'moon.list' )

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local listify = assert( list.listify )

-----------------------------------------------------------------
-- Set type.
-----------------------------------------------------------------
local function create_set( lst )
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

  function methods.list( self )
    assert( self == o, 'set called with incorrect self object' )
    return listify( self )
  end

  function methods.clear( self )
    assert( self == o, 'set called with incorrect self object' )
    contents = {}
    size = 0
  end

  local mt = {
    __index=methods,
    __newindex=function()
      error( 'cannot set members of a set', 2 )
    end,
    __len=function() return size end,
    __pairs=function()
      error( 'a set does not have pairs: use items()', 2 )
    end,
    __ipairs=function()
      error( 'set items are not ordered: use items()', 2 )
    end,
    -- This allows: for e in s do ... end
    __call=function( _, _, key ) return next( contents, key ) end,

  }

  local res = setmetatable( o, mt )

  for _, elem in ipairs( lst ) do res:add( elem ) end

  return res
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return create_set
