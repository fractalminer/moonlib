CXX       ?= g++
CXXFLAGS  ?= -O2
CXXFLAGS  += -Wall -Wextra -Wpedantic -fPIC

LUA_VERSION ?= 5.4

LUA_CFLAGS := $(shell pkg-config --cflags lua$(LUA_VERSION))
LUA_LIBS   := $(shell pkg-config --libs lua$(LUA_VERSION))
ZSTD_LIBS  := -lzstd

PREFIX     ?= $(HOME)/.local
LUA_CMOD   ?= $(PREFIX)/lib/lua/$(LUA_VERSION)
MOON_CMOD  ?= $(LUA_CMOD)/moon

BUILD_OUT  := .build
TARGET     := $(BUILD_OUT)/zstd.so

# 2. Dynamic File Discovery using $(wildcard) & Text Manipulation
SRCS       := $(wildcard src/*.cpp)
OBJS       := $(patsubst src/%.cpp, $(BUILD_OUT)/%.o, $(SRCS))

# Fixed: This extracts 'zstd.so' and appends it to your destination path
INSTALLED  := $(MOON_CMOD)/$(notdir $(TARGET))

.PHONY: all install clean

# 3. Keeps intermediate .o files so Make doesn't issue an automatic 'rm'
.SECONDARY: $(OBJS)

all: $(TARGET)

# Compile Rule.
$(BUILD_OUT)/%.o: src/%.cpp Makefile
	@mkdir -p $(BUILD_OUT)
	$(CXX) $(CXXFLAGS) $(LUA_CFLAGS) -c -o $@ $<

# Link Rule.
$(TARGET): $(OBJS) Makefile
	@mkdir -p $(BUILD_OUT)
	$(CXX) -shared -o $@ $(OBJS) $(LUA_LIBS) $(ZSTD_LIBS)

# Install Rules.
$(INSTALLED): $(TARGET) Makefile
	mkdir -p $(MOON_CMOD)
	install -m 755 $(TARGET) $(INSTALLED)

install: $(INSTALLED)

clean:
	rm -rf $(BUILD_OUT)