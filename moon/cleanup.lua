-----------------------------------------------------------------
-- Scope Guard.
-----------------------------------------------------------------
local M = {}

-----------------------------------------------------------------
-- Cleanup MT.
-----------------------------------------------------------------
local cleanup_mt = {}

function cleanup_mt.__close( self )
  if self._released then return end
  self.fn()
  self:release()
end

function cleanup_mt.__newindex() error( 'cannot set new fields' ) end

cleanup_mt.__index = cleanup_mt

function cleanup_mt.release( self )
  assert( self, 'missing member object' )
  rawset( self, '_released', true )
end

function cleanup_mt.cleanup_now( self )
  assert( self, 'missing member object' )
  self:__close()
end

-----------------------------------------------------------------
-- Methods.
-----------------------------------------------------------------
function M.cleanup( fn )
  assert( fn )
  local o = { fn=fn }
  return setmetatable( o, cleanup_mt )
end

function M.cleaned() return M.cleanup( function() end ) end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return M
