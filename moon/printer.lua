-----------------------------------------------------------------
-- Printing methods.
-----------------------------------------------------------------
local M = {}

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local console = require'moon.console'
local str = require'moon.str'
local mtbl = require'moon.tbl'

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local concat = table.concat
local format = string.format
local insert = table.insert
local max = math.max
local on_ordered_kv = mtbl.on_ordered_kv

local trim_right = str.trim_right
local terminal_columns_safe = console.terminal_columns_safe

-----------------------------------------------------------------
-- Implementation.
-----------------------------------------------------------------
function M.printf( fmt, ... )
  fmt = fmt or ''
  io.write( format( fmt, ... ) )
end

function M.printfln( fmt, ... ) M.printf( fmt .. '\n', ... ) end

function M.bar( c )
  c = c or '-'
  local cols = terminal_columns_safe()
  local dashes = string.rep( c, cols )
  print( dashes )
end

function M.title( title, c )
  title = title and ' ' .. title .. ' ' or ''
  c = c or '-'
  local cols = terminal_columns_safe()
  local cols_l = 2
  local cols_r = max( cols - cols_l - #title, 0 )
  local dashes_l = string.rep( c, cols_l )
  local dashes_r = string.rep( c, cols_r )
  print( dashes_l .. title .. dashes_r )
end

-- Given this input:
--
--   local desc = {
--     column_names={ 'col1', 'col2', 'col3', 'col4' },
--     row_names={ 'row1', 'row2', 'row3' },
--     data={
--       { '11', '12', '13',      '14' },
--       { '21', '22', '23_long', '24' },
--       { '31', '32', '33',      '34' },
--     },
--   }
--
-- returns these rows:
--
--   {
--     "        col1  col2     col3  col4",
--     "row1      11    12       13    14",
--     "row2      21    22  23_long    24",
--     "row3      31    32       33    34",
--   }
--
function M.format_data_table_rows( desc )
  assert( desc.column_names )
  assert( desc.row_names )
  assert( desc.data )
  assert( #desc.data == #desc.row_names )
  if #desc.row_names > 0 then
    assert( #desc.data[1] == #desc.column_names )
  end
  local res = { '' }

  local function emit( what ) res[#res] = res[#res] .. what end

  local function newline() insert( res, '' ) end

  if #desc.column_names == 0 or #desc.row_names == 0 then
    return {}
  end

  local function max_width( values )
    local width = 0
    for _, e in ipairs( values ) do
      local s = tostring( e )
      width = max( width, #s )
    end
    return width + 2
  end

  local widths = { max_width( desc.row_names ) }
  for i, _ in ipairs( desc.column_names ) do
    local values = { desc.column_names[i] }
    for row = 1, #desc.row_names do
      insert( values, desc.data[row][i] )
    end
    insert( widths, max_width( values ) )
  end

  local function emit_cell_left( col, what )
    local fmt = format( '%%-%ds', assert( widths[col] ) )
    emit( format( fmt, what ) )
  end

  local function emit_cell_right( col, what )
    local fmt = format( '%%%ds', assert( widths[col] ) )
    emit( format( fmt, what ) )
  end

  emit_cell_left( 1, '' )
  for i, col_name in ipairs( desc.column_names ) do
    emit_cell_right( i + 1, col_name )
  end
  newline()

  for row_idx, row_name in ipairs( desc.row_names ) do
    emit_cell_left( 1, row_name )
    local data_row = desc.data[row_idx]
    assert( type( data_row ) == 'table' )
    for i, _ in ipairs( desc.column_names ) do
      emit_cell_right( i + 1, assert( data_row[i] ) )
    end
    newline()
  end

  for i = 1, #res do res[i] = trim_right( res[i] ) end

  return res
end

-- Same as above but joins the result into a string.
function M.format_data_table( desc )
  return trim_right( concat( M.format_data_table_rows( desc ),
                             '\n' ) )
end

-- Same as above but prints the result.
function M.print_data_table( desc )
  print( M.format_data_table( desc ) )
end

-- Formats a table's key/value pairs into a single line. E.g.
-- if we have this table:
--
--   local tbl = {
--     hello=1,
--     world='foo',
--   }
--
-- and we call this:
--
--   format_kv_table( tbl, {
--     start='[',
--     ending=']',
--     kv_sep='=',
--     pair_sep='|',
--   } )
--
-- we will obtain the following string:
--
--   [hello=1|world=foo]
--
-- NOTE: the keys are sorted in alphabetical order.
--
function M.format_kv_table( tbl, args )
  args = args or {}
  local start = args.start or ''
  local ending = args.ending or ''
  local kv_sep = args.kv_sep or '='
  local pair_sep = args.pair_sep or ','
  pair_sep = ''
  local line = ''
  on_ordered_kv( tbl, function( k, v )
    line = format( '%s%s%s%s%s', line, pair_sep, k, kv_sep,
                   tostring( v ) )
    pair_sep = args.pair_sep or ','
  end )
  return format( '%s%s%s', start, line, ending )
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return M
