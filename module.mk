#
#	module.mk			(C) 2007-2008, Aurélien Croc (AP²C)
#
#  Compilation file for SpliX
#
# Options: DISABLE_JBIG
# 	   DISABLE_THREADS
#          DISABLE_BLACKOPTIM
# Compilation option:
# 	   V=1          Verbose mode
# 	   DESTDIR=xxx  Change the destination directory prefix
# 	   DRV_ONLY     Don't install PPD files at all, only DRV files.

MODE			:= optimized

SUBDIRS 		+= src
TARGETS			:= rastertoqpdl pstoqpdl
PRE_GENERIC_TARGETS	:= optionList


# Default options
THREADS			?= 2
CACHESIZE		?= 30
DISABLE_JBIG		?= 0
DISABLE_THREADS		?= 0
DISABLE_BLACKOPTIM	?= 0
DRV_ONLY		?= 0


# CUPS
# On macOS CUPS ships with the system: the headers and the linker stubs live
# in the SDK and /usr/bin/cups-config resolves them without any extra
# environment. pkg-config is useless here (cups is keg-only in Homebrew) and it
# breaks `sudo make install`, because sudo resets PKG_CONFIG_PATH and the link
# line is then built without -lcups.
ifeq ($(ARCHI),Darwin)
CUPS_CONFIG		?= /usr/bin/cups-config
CUPS_CFLAGS		:= `$(CUPS_CONFIG) --cflags`
CUPS_LIBS		:= `$(CUPS_CONFIG) --libs`
CUPS_DATADIR		:= `$(CUPS_CONFIG) --datadir`
else
CUPS_CFLAGS		:= `pkg-config --cflags cups`
CUPS_LIBS		:= `pkg-config --libs cups`
CUPS_DATADIR		:= `pkg-config --variable=cups_datadir cups`
endif


# Flags
CXXFLAGS		+= $(CUPS_CFLAGS) -Iinclude -Wall -I/opt/local/include
DEBUG_CXXFLAGS		+= -DDEBUG  -DDUMP_CACHE
OPTIM_CXXFLAGS 		+= -g
rastertoqpdl_LDFLAGS	:= $(LDFLAGS) -L/opt/local/lib
rastertoqpdl_LIBS	:= $(CUPS_LIBS) -lcupsimage
pstoqpdl_LDFLAGS	:= $(LDFLAGS)
pstoqpdl_LIBS		:= $(CUPS_LIBS) -lcupsimage

ifeq ($(ARCHI),Darwin)
# Homebrew prefix (needed for jbig85) is derived from the disk instead of
# running `brew --prefix`, which fails for root: sudo drops $HOME and PATH.
BREW_PREFIX		?= $(patsubst %/bin/brew,%,$(firstword $(wildcard \
			   /opt/homebrew/bin/brew /usr/local/bin/brew)))
CXXFLAGS		+= $(if $(BREW_PREFIX),-I$(BREW_PREFIX)/include)
rastertoqpdl_LDFLAGS	+= $(if $(BREW_PREFIX),-L$(BREW_PREFIX)/lib)
pstoqpdl_LDFLAGS	+= $(if $(BREW_PREFIX),-L$(BREW_PREFIX)/lib)
endif

# Update compilation flags with defined options
ifneq ($(DISABLE_THREADS),0)
CXXFLAGS		+= -DDISABLE_THREADS
else
CXXFLAGS		+= -DTHREADS=$(THREADS) -DCACHESIZE=$(CACHESIZE)
rastertoqpdl_LIBS	+= -lpthread
pstoqpdl_LIBS		+= -lpthread
endif
ifneq ($(DISABLE_JBIG),0)
CXXFLAGS		+= -DDISABLE_JBIG
else
rastertoqpdl_LIBS	+= -ljbig85
endif
ifneq ($(DISABLE_BLACKOPTIM),0)
CXXFLAGS		+= -DDISABLE_BLACKOPTIM
endif


# Get some information
CUPSFILTER		:= `$(CUPS_CONFIG) --serverbin`/filter
ifeq ($(ARCHI),Darwin)
CUPSPPD			:= /Library/Printers/PPDs/Contents/Resources
else
CUPSPPD			?= `$(CUPS_CONFIG) --datadir`/model
endif
CUPSDRV			?= `$(CUPS_CONFIG) --datadir`/drv
ifeq ($(ARCHI),Darwin)
PSTORASTER		:= pstocupsraster
else
PSTORASTER		:= pstoraster
endif
GSTORASTER		:= gstoraster
CUPSPROFILE		:= $(CUPS_DATADIR)/profiles
export CUPSFILTER CUPSPPD CUPSDRV


# Specific information needed by pstoqpdl
src_pstoqpdl_cpp_FLAGS	:= -DRASTERDIR=\"$(CUPSFILTER)\"
src_pstoqpdl_cpp_FLAGS	+= -DRASTERTOQPDL=\"rastertoqpdl\"
src_pstoqpdl_cpp_FLAGS	+= -DPSTORASTER=\"$(PSTORASTER)\"
src_pstoqpdl_cpp_FLAGS	+= -DGSTORASTER=\"$(GSTORASTER)\"
src_pstoqpdl_cpp_FLAGS	+= -DCUPSPPD=\"$(CUPSPPD)\"
src_pstoqpdl_cpp_FLAGS	+= -DCUPSPROFILE=\"$(CUPSPROFILE)\"

