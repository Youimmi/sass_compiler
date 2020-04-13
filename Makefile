ifeq ($(ERL_EI_INCLUDE_DIR),)
	ERL_ROOT_DIR = $(shell erl -eval "io:format(\"~s~n\", [code:root_dir()])" -s init stop -noshell)

	ifeq ($(ERL_ROOT_DIR),)
		$(error Could not find the Erlang installation. Check to see that 'erl' is in your PATH)
	endif

	ERL_EI_INCLUDE_DIR = "$(ERL_ROOT_DIR)/usr/include"
	ERL_EI_LIBDIR = "$(ERL_ROOT_DIR)/usr/lib"
endif

SASS_DIR = libsass
LIB_NAME = priv/sass_nif.so

# Set Erlang-specific compile and linker flags
ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR) -Ilibsass -Ilibsass/include
ERL_LDFLAGS ?= -Ilibsass -Ilibsass/include -Llibsass/lib

LDFLAGS += -fPIC -shared
CFLAGS ?= -fPIC -O3 -Wall -Wextra
CC = $(CROSSCOMPILER)g++

ifeq ($(CROSSCOMPILE),)
	ifeq ($(shell uname),Darwin)
		LDFLAGS += -undefined dynamic_lookup
	endif
endif

NPROCS := 1
OS := $(shell uname)
export NPROCS

ifeq ($J,)

ifeq ($(OS),Linux)
  NPROCS := $(shell grep -c ^processor /proc/cpuinfo)
else ifeq ($(OS),Darwin)
  NPROCS := $(shell sysctl -n hw.logicalcpu)
endif # $(OS)

else
  NPROCS := $J
endif # $J

all: libsass-make $(LIB_NAME)

clean: libsass-clean sass_compiler-clean

libsass-clean:
	$(MAKE) -C $(SASS_DIR) clean

libsass-make:
	$(MAKE) -C $(SASS_DIR) -j$(NPROCS)

%.o: %.c
	$(CC) -x c++ -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

$(LIB_NAME): c_src/sass_nif.o
	mkdir -p priv
	$(CC) $^ $(ERL_LDFLAGS) $(LDFLAGS) -Bstatic -lsass -lm -lc -o $@

sass_compiler-clean:
	rm -rf _build libsass/lib priv/sass_nif.so && rm -f c_src/*.o

.PHONY: all clean
