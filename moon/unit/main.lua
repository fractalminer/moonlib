-----------------------------------------------------------------
-- Runs a group of unit test files.
-----------------------------------------------------------------
-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local colors = require'moon.colors'
local err = require'moon.err'
local printer = require'moon.printer'
local setup = require'moon.unit.setup'
local console = require'moon.console'
local tbl = require'moon.tbl'

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local count_keys = tbl.count_keys
local format = string.format
local rep = string.rep
local sort = table.sort
local insert = table.insert
local pcall = err.pcall_traceback
local printfln = printer.printfln
local terminal_width_safe = console.terminal_columns_safe
local min = math.min
local max = math.max

-----------------------------------------------------------------
-- Constants.
-----------------------------------------------------------------
local GREEN = colors.ANSI_GREEN
local BLUE = colors.ANSI_BLUE
local NORMAL = colors.ANSI_NORMAL
local RED = colors.ANSI_RED
local YELLOW = colors.ANSI_INTENSE_YELLOW
local MAGENTA = colors.ANSI_MAGENTA

local MAX_WIDTH = 100

-----------------------------------------------------------------
-- Methods.
-----------------------------------------------------------------
local function run_test_cases( module_name, pack )
  local sorted_names = {}
  local longest_length = 0
  for name in pairs( pack ) do
    if #name > longest_length then longest_length = #name end
    insert( sorted_names, name )
  end
  sort( sorted_names )
  local w = min( MAX_WIDTH, terminal_width_safe() )
  local PREFIX = 'test case: '
  for _, name in ipairs( sorted_names ) do
    local text_no_colors = format( '%s%s.%s', PREFIX,
                                   module_name, name )
    local num_dots = w - #text_no_colors - #' passed' -- or failed
    num_dots = max( num_dots, 3 )
    io.write( format( '%s%s%s%s.%s%s%s%s', PREFIX, MAGENTA,
                      module_name, NORMAL, BLUE, name, NORMAL,
                      rep( '.', num_dots ) ) )
    io.flush()
    local ok, res = pcall( pack[name] )
    if ok then
      printfln( '%s passed%s', GREEN, NORMAL )
    else
      printfln( '%s failed%s', RED, NORMAL )
      printfln( '%s%s%s', YELLOW, res, NORMAL )
      return false
    end
  end
  return true
end

-----------------------------------------------------------------
-- Main.
-----------------------------------------------------------------
local function main( files )
  for _, file in ipairs( files ) do
    local f = assert( loadfile( file ) )
    local test_pack = assert( setup.new_pack() )
    assert( type( test_pack ) == 'table' )
    f( test_pack )
    -- Ensure that there is at least one test case.
    assert( count_keys( test_pack ) > 0 )
    local module_name = assert( file:match( '(.*)%.lua' ) )
    local ok = run_test_cases( module_name, test_pack )
    if not ok then break end
  end
end

main{ ... }
