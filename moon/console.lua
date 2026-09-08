-----------------------------------------------------------------
-- Terminal/Console related things.
-----------------------------------------------------------------
local M = {}

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local cterm = require( 'moon.cterm' )

-----------------------------------------------------------------
-- Constants.
-----------------------------------------------------------------
local DEFAULT_COLUMNS = 65

-----------------------------------------------------------------
-- Methods.
-----------------------------------------------------------------
function M.terminal_columns()
  local _, columns = cterm.size()
  assert( columns )
  assert( type( columns ) == 'number' )
  assert( columns >= 0 )
  return columns
end

function M.terminal_columns_safe()
  local success, val = pcall( M.terminal_columns )
  if not success then return DEFAULT_COLUMNS end
  return val
end

function M.is_wide_terminal()
  local cols = M.terminal_columns_safe()
  return cols > 250
end

function M.clear_screen()
  -- Clears screen and moves cursor to top-left.
  io.write( '\27[H\27[2J' )
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return M
