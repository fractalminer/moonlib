-----------------------------------------------------------------
-- Error-handling utilities.
-----------------------------------------------------------------
local M = {}

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local unpack = table.unpack
local remove = table.remove
local traceback = assert( debug.traceback )

-----------------------------------------------------------------
-- Implementation.
-----------------------------------------------------------------
-- This can be used to replace pcall; it attaches the traceback
-- to the error message.
function M.pcall_traceback( f, ... )
  return xpcall( f, traceback, ... )
end

function M.catch_control_c( fn, on_ctrl_c )
  local res = { M.pcall_traceback( fn ) }
  if res[1] then
    -- success.
    remove( res, 1 )
    return unpack( res )
  end
  local msg = res[2] or ''
  -- We have an error. If it is from <C-c> and if we are running
  -- the standard lua interpreter then the error message will be
  -- "interrupted!".
  if msg:find( 'interrupted!' ) then
    if on_ctrl_c then return on_ctrl_c() end
    return
  end
  error( msg )
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return M
