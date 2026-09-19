CXX       ?= g++
CXXFLAGS  ?= -O2
CXXFLAGS  += -std=c++20 -Wall -Wextra -Wpedantic -fPIC

LUA_VERSION ?= 5.4

LUA_CFLAGS := $(shell pkg-config --cflags lua$(LUA_VERSION))
LUA_LIBS   := $(shell pkg-config --libs lua$(LUA_VERSION))

ZSTD_LIBS   := -lzstd

PKG_CONFIG_PATH := $(HOME)/.local/lib/pkgconfig

XDELTA_CFLAGS := $(shell \
  PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --cflags xdelta3)
XDELTA_LIBS := $(shell \
  PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --libs xdelta3)

PREFIX     ?= $(HOME)/.local
LUA_CMOD   ?= $(PREFIX)/lib/lua/$(LUA_VERSION)
MOON_CMOD  ?= $(LUA_CMOD)/moon

OUTDIR     := .build

HDRS       := src/common.hpp

# 1. Map each source file to its own target .so file.
SRCS       := $(wildcard src/*.cpp)
OBJS       := $(patsubst src/%.cpp, $(OUTDIR)/%.o, $(SRCS))
TARGETS    := $(patsubst src/%.cpp, $(OUTDIR)/%.so, $(SRCS))

# 2. Map target .so files to their individual installation paths.
INSTALLED  := $(patsubst $(OUTDIR)/%.so, $(MOON_CMOD)/%.so, $(TARGETS))

.PHONY: all install clean

# Prevents automatic deletion of intermediate object files.
.SECONDARY: $(OBJS)

# Builds all independent .so libraries.
all: $(TARGETS)

# Compile (xdelta).
$(OUTDIR)/xdelta.o: src/xdelta.cpp $(HDRS) Makefile
	@mkdir -p $(OUTDIR)
	$(CXX) $(CXXFLAGS) $(LUA_CFLAGS) $(XDELTA_CFLAGS) \
	  -I$(HOME)/.local/include \
	  -c -o $@ $<

# Compile (generic).
$(OUTDIR)/%.o: src/%.cpp $(HDRS) Makefile
	@mkdir -p $(OUTDIR)
	$(CXX) $(CXXFLAGS) $(LUA_CFLAGS) \
	  -c -o $@ $<

# Link (zstd).
$(OUTDIR)/zstd.so: $(OUTDIR)/zstd.o Makefile
	@mkdir -p $(OUTDIR)
	$(CXX) -shared -o $@ $< $(LUA_LIBS) $(ZSTD_LIBS)

# Link (xdelta).
$(OUTDIR)/xdelta.so: $(OUTDIR)/xdelta.o Makefile
	@mkdir -p $(OUTDIR)
	$(CXX) -shared -o $@ $< $(LUA_LIBS) $(XDELTA_LIBS)

# Link (generic). For modules that don't need any special libs
# linked to them.
$(OUTDIR)/%.so: $(OUTDIR)/%.o Makefile
	@mkdir -p $(OUTDIR)
	$(CXX) -shared -o $@ $< $(LUA_LIBS) $(ZSTD_LIBS)

# Install step.
$(INSTALLED): $(MOON_CMOD)/%.so: $(OUTDIR)/%.so Makefile
	@mkdir -p $(MOON_CMOD)
	install -m 755 $< $@

install: $(INSTALLED)

clean:
	rm -rf $(OUTDIR)