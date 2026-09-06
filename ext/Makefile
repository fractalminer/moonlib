CXX     ?= CXX
CFLAGS  ?= -O2
CFLAGS  += -Wall -Wextra -Wpedantic -fPIC

LUA_VERSION ?= 5.4

LUA_CFLAGS := $(shell pkg-config --cflags lua$(LUA_VERSION))
LUA_LIBS   := $(shell pkg-config --libs lua$(LUA_VERSION))
ZSTD_LIBS  := -lzstd

PREFIX     ?= $(HOME)/.local
LUA_CMOD   ?= $(PREFIX)/lib/lua/$(LUA_VERSION)
MOON_CMOD  ?= $(LUA_CMOD)/moon

TARGET := zstd.so
OBJECT := zstd.o

INSTALLED  := $(MOON_CMOD)/$(TARGET)

.PHONY: all install clean

all: $(TARGET)

# Compile.
$(OBJECT): src/zstd.cpp Makefile
	$(CXX) $(CFLAGS) $(LUA_CFLAGS) -c -o $@ $<

# Link.
$(TARGET): $(OBJECT) Makefile
	$(CXX) -shared -o $@ $< $(LUA_LIBS) $(ZSTD_LIBS)

$(INSTALLED): $(TARGET) Makefile
	mkdir -p $(MOON_CMOD)
	install -m 755 $(TARGET) $(INSTALLED)

install: $(INSTALLED)

clean:
	rm -f $(TARGET)