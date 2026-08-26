-----------------------------------------------------------------
-- Tests for the cleanup module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require'moon.unit.assertion'
local mcleanup = require'moon.cleanup'

-----------------------------------------------------------------
-- Freeze global access.
-----------------------------------------------------------------
-- Declare all globals used.
local assert = assert

-- No reading or writing of globals from here on.
local _ENV = nil

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local ASSERT_EQ = assertion.ASSERT_EQ

local cleanup = assert( mcleanup.cleanup )
local cleaned = assert( mcleanup.cleaned )

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.cleanup()
  local n_called = 0

  local fn = function() n_called = n_called + 1 end

  do
    ASSERT_EQ( n_called, 0 )
    local _<close> = cleanup( fn )
    ASSERT_EQ( n_called, 0 )
  end
  ASSERT_EQ( n_called, 1 )

  do
    ASSERT_EQ( n_called, 1 )
    local _<close> = cleanup( fn )
    local _<close> = cleanup( fn )
    ASSERT_EQ( n_called, 1 )
  end
  ASSERT_EQ( n_called, 3 )

  do
    ASSERT_EQ( n_called, 3 )
    local _1<close> = cleanup( fn )
    local _2<close> = cleanup( fn )
    ASSERT_EQ( n_called, 3 )
    _1:release()
  end
  ASSERT_EQ( n_called, 4 )

  do
    ASSERT_EQ( n_called, 4 )
    local _1<close> = cleanup( fn )
    local _2<close> = cleanup( fn )
    _1:release()
    _2:release()
    ASSERT_EQ( n_called, 4 )
  end
  ASSERT_EQ( n_called, 4 )

  do
    ASSERT_EQ( n_called, 4 )
    local _<close> = cleanup( fn )
    _:cleanup_now()
    ASSERT_EQ( n_called, 5 )
  end
  ASSERT_EQ( n_called, 5 )

  do
    ASSERT_EQ( n_called, 5 )
    local _<close> = cleaned( fn )
    ASSERT_EQ( n_called, 5 )
  end
  ASSERT_EQ( n_called, 5 )

  do
    ASSERT_EQ( n_called, 5 )
    local _<close> = cleanup( fn )
    ASSERT_EQ( n_called, 5 )
  end
  ASSERT_EQ( n_called, 6 )
end
