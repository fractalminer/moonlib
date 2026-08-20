-----------------------------------------------------------------
-- JSON reading and writing.
-----------------------------------------------------------------
local M = {}

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local lunajson = require( 'lunajson' )
local time = require( 'moon.time' )
local logger = require( 'moon.logger' )

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local yield = coroutine.yield
local timeit_micros = time.timeit_micros
local dbg = logger.dbg
local format = string.format

-----------------------------------------------------------------
-- Constants.
-----------------------------------------------------------------
local DEFAULT_INDENT = 2

M.JNULL = {}

-----------------------------------------------------------------
-- Implementation.
-----------------------------------------------------------------
local function list_mt()
  local storage = { [0]=0 }
  return {
    __index=function( _, i )
      local length = assert( storage[0] )
      assert( type( length ) == 'number' )
      assert( math.type( length ) == 'integer' )
      assert( type( i ) == 'number' )
      assert( math.type( i ) == 'integer' )
      if i == 0 then return storage[0] end
      if i > length then return nil end
      local val = storage[i]
      if val == nil then return M.JNULL end
      return val
    end,
    __newindex=function( _, i, val )
      local length = assert( storage[0] )
      assert( type( length ) == 'number' )
      assert( math.type( length ) == 'integer' )
      assert( type( i ) == 'number' )
      assert( math.type( i ) == 'integer' )
      assert( i >= 1, 'indices start with 1' )
      storage[i] = val
      if val == nil then
        storage[0] = math.min( i - 1, length )
      else
        if i > 1 and storage[i - 1] == nil then
          -- Can insert at the ned, but not beyond the end.
          error( 'index out of bounds', 2 )
        end
        -- Set new length.
        if i > length then storage[0] = i end
      end
    end,
    __len=function( _ )
      local length = assert( storage[0] )
      return length
    end,
    __metatable=false,
  }
end

-- Creates a new list. A list object is a lua list that tracks
-- the length of the list in the [0] item so that we can 1) dis-
-- tinguish empty lists from empty tables, and 2) so that we can
-- have nil values, which will be exposed as JNULL. That said, if
-- you want to store a nil value in the list you need to use
-- JNULL, otherwise the act of storing nil will truncate the
-- list.
function M.list() return setmetatable( {}, list_mt() ) end

-- Decode a string of json.
function M.decode( json_string )
  -- Start decoding from the start of the string.
  local pos = 0
  -- `null` inside the json will be decoded as this sentinel.
  local nullv = M.JNULL
  -- Store the length of an array in array[0]. This can be used
  -- to distinguish empty arrays from empty objects.
  local arraylen = true
  local decode_time, tbl = timeit_micros( function()
    return lunajson.decode( json_string, pos, nullv, arraylen )
  end )
  dbg( 'json decode time: %dms', decode_time // 1000 )
  assert( tbl )
  return tbl
end

M.read = assert( M.decode )

function M.read_file( path )
  local f<close> = assert( io.open( path, 'r' ) )
  return assert( M.read( f:read( '*all' ) ) )
end

-- Coroutine generator function that pretty-prints a layout in
-- conforming JSON while preserving key ordering. Each time a
-- line is produced it will yield it.
local function pprint_ordered_impl( append, o, indent, spaces )
  indent = indent or DEFAULT_INDENT
  spaces = spaces or ''
  assert( type( indent ) == 'number',
          format(
              'indent must be a number but instead is of type "%s"',
              type( indent ) ) )
  assert( type( spaces ) == 'string' )
  if o == M.JNULL or o == nil then
    append( 'null' )
  elseif type( o ) == 'table' and not o[0] and not o[1] then
    -- Object.
    append( '{' )
    spaces = spaces .. string.rep( ' ', indent )
    local keys = {}
    if o.__key_order then
      for _, k in ipairs( o.__key_order ) do
        assert( type( k ) == 'string' )
        if not k:match( '^_' ) then
          table.insert( keys, k )
        end
      end
    else
      for k, _ in pairs( o ) do
        assert( type( k ) == 'string', tostring( k ) )
        if not k:match( '^_' ) then
          table.insert( keys, k )
        end
      end
      table.sort( keys )
    end
    if #keys == 0 then
      append( '}' )
      return
    end
    append()
    for i, k in ipairs( keys ) do
      assert( o[k] ~= nil, 'key not found: ' .. tostring( k ) )
      local v = o[k]
      k = '"' .. k .. '"'
      local colon = (indent > 0) and ': ' or ':'
      append( spaces .. k .. colon )
      pprint_ordered_impl( append, v, indent, spaces )
      if i ~= #keys then append( ',' ) end
      append()
    end
    append( string.sub( spaces, 3 ) .. '}' )
  elseif type( o ) == 'table' and (o[0] or o[1]) then
    -- Array.
    append( '[' )
    local length = o[0] and o[0] or #o
    assert( type( length ) == 'number' )
    if length == 0 then
      append( ']' )
      return
    end
    append()
    spaces = spaces .. string.rep( ' ', indent )
    for i = 1, length do
      local e = o[i] -- might be nil, that's ok.
      append( spaces )
      pprint_ordered_impl( append, e, indent, spaces )
      if i ~= #o then append( ',' ) end
      append()
    end
    append( string.sub( spaces, 3 ) .. ']' )
  elseif type( o ) == 'string' then
    append( '"' .. tostring( o ) .. '"' )
  else
    append( tostring( o ) )
  end
end

local function appender()
  local res = ''
  return function( segment )
    if not segment then
      -- flush line.
      yield( res )
      res = ''
    else
      res = res .. segment
    end
  end
end

-- Returns a coroutine generator that pretty-prints a layout in
-- conforming JSON while preserving key ordering. Each time a
-- line is produced it will yield it.
function M.pprint_ordered( o, indent )
  indent = indent or DEFAULT_INDENT
  local append = appender()
  local printer = coroutine.wrap( function()
    pprint_ordered_impl( append, o, indent )
    append() -- emit final brace.
  end )
  return printer
end

local function write_with_sep( emit, o, SEP, indent )
  assert( type( SEP ) == 'string' )
  indent = indent or DEFAULT_INDENT
  emit = emit or function( ... ) io.stdout:write( ... ) end
  local printer = M.pprint_ordered( o, indent )
  local sep = ''
  for line in printer do
    emit( sep )
    sep = SEP
    emit( line )
  end
end

function M.write_pretty( o, indent, emit )
  indent = indent or DEFAULT_INDENT
  local sep = '\n'
  return write_with_sep( emit, o, sep, indent )
end

function M.write_oneline( o, emit )
  local indent = 0
  local sep = ' '
  return write_with_sep( emit, o, sep, indent )
end

M.write = assert( M.write_pretty )
M.print = function( o, indent, emit )
  emit = emit or function( ... ) io.stdout:write( ... ) end
  M.write_pretty( o, indent, emit )
  emit( '\n' )
end

function M.tostring( o )
  local lines = {}
  local function emit( line ) table.insert( lines, line ) end
  local sep = ''
  local indent = 0
  write_with_sep( emit, o, sep, indent )
  return table.concat( lines )
end

function M.tostring_pretty( o, indent )
  local lines = {}
  local function emit( line ) table.insert( lines, line ) end
  local sep = '\n'
  write_with_sep( emit, o, sep, indent )
  return table.concat( lines )
end

function M.write_file( filename, o, indent )
  assert( type( filename ) == 'string',
          'file name expected in first argument' )
  local out<close> = assert( io.open( filename, 'w' ) )
  local function emit( line ) out:write( line ) end
  return M.write_pretty( o, indent, emit )
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return M