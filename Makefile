PROJECT			:= rpi_ws281x
VERSION			:= $(shell cat version | sed 's/[[:space:]]//g')
VERSION_MAJOR	:= $(shell cat version | sed 's/[[:space:]]//g' | cut -d '.' -f1)
VERSION_MINOR	:= $(shell cat version | sed 's/[[:space:]]//g' | cut -d '.' -f2)
VERSION_MICRO	:= $(shell cat version | sed 's/[[:space:]]//g' | cut -d '.' -f3)
COMMIT			:= $(shell git rev-parse --short HEAD)
DESCRIPTION		:= $(shell echo "Userspace Raspberry Pi PWM library for WS281x LEDs")


# base CFLAGS
CFLAGS := -fPIC -g -O2 -Wall -Wextra -Werror
LDFLAGS := -lrt
# Verbose control
ifeq ($(V),)
HIDE=@
endif

ifeq ($(SYSROOT),)
SYSROOT := /user
endif

ifeq ($(BUILDDIR),)
BUILDDIR := build
endif

ifeq ($(RANLIB),)
RANLIB := ranlib
endif

ifeq ($(INSTALL),)
INSTALL := install
endif

ifeq ($(DPKG_BUILD),)
DPKG_BUILD := dpkg-deb --build
endif

INCLUDES := -I. -I$(SYSROOT)/include
LDFLAGS += -L$(BUILDDIR) -L$(SYSROOT)/lib

include version.mk
include pkg.mk

objs := mailbox.o ws2811.o pwm.o pcm.o dma.o rpihw.o

prepare:
	@mkdir -p $(BUILDDIR)

# %.os : %.c prepare
# 	$(HIDE)$(CC) $(CFLAGS) $< -o $(BUILDDIR)/$@

%.o : %.c version.h prepare
	$(HIDE)$(CC) -c $(CFLAGS) $(INCLUDES) $< -o $(BUILDDIR)/$@

build: $(objs) main.o
	$(HIDE)$(AR) rcs $(BUILDDIR)/libws2811.a $(patsubst %,$(BUILDDIR)/%,$(objs))
	$(HIDE)$(RANLIB) $(BUILDDIR)/libws2811.a
	$(HIDE)$(CC) $(BUILDDIR)/main.o -static $(LDFLAGS) -lws2811 -o $(BUILDDIR)/test

shared: build
	$(HIDE)$(CC) -shared -fPIC -Wl,-soname,libws2811.so -o $(BUILDDIR)/libws2811.so $(patsubst %,$(BUILDDIR)/%,$(objs)) -lc

clean: clean_pkg
	@rm -rf $(BUILDDIR)/*.o
	@rm -rf $(BUILDDIR)/*.a
	@rm -rf $(BUILDDIR)/*.so
	@rm -rf $(BUILDDIR)/test
	@rm -f version.h
