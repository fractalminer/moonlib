-----------------------------------------------------------------
-- Set Type.
-----------------------------------------------------------------
local list = require( 'moon.list' )

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local listify = assert( list.listify )

local yield = assert( coroutine.yield )

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
    return listify( pairs( contents ) )
  end

  function methods.iter( self )
    assert( self == o, 'set called with incorrect self object' )
    return pairs( contents )
  end

  local mt = {
    __index=methods,
    __newindex=function()
      error( 'cannot set members of a set', 2 )
    end,
    __length=function() return size end,
    __pairs=function() return pairs( contents ) end,
    __ipairs=function() return ipairs( contents ) end,
  }

  local res = setmetatable( o, mt )

  for _, elem in ipairs( lst ) do res:add( elem ) end

  return res
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return create_set
