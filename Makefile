# Makefile for MESH ( http://mesh.is/ )
# (c) 2014 David Dalrymple
# See LICENSE for your rights to this software and README.md for instructions.

#-------------------------------------------------------------------------------
# Setting variables
VERSION ?= 0.0.1

# GNU Make will see all files in these directories as if they were top-level.
VPATH = download

# Detect OS.
UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
	PLATFORM := darwin
	# This means we are running on OSX.
endif
ifeq ($(UNAME),Linux)
	PLATFORM := linux
endif
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Default rule. Intended to build a mesh binary for the current platform.
mesh.bin: boot.bin
	cat $^ > $@
	@echo "Now run 'make q' (assumes you have qemu 1.7.0 installed) to launch MeshOS within QEMU."
-include *.dep
%.bin: nasm %.asm
	nasm $*.asm -o $@ -MD $*.dep
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Run within QEMU
.PHONY: q
q: mesh.bin
	qemu-system-x86_64 -cpu SandyBridge mesh.bin
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Download NASM.
NASM_DL_VERSION := 2.11
download: ; mkdir download

ifeq ($(PLATFORM),darwin)
    # local filename to save
    NASM_DL := nasm-osx.zip

    # intermediate component of NASM binary URL
    NASM_DL_PLATFORM := macosx

    # final component of NASM binary URL
    NASM_DL_EXT := -macosx.zip

    # git hash-object
    NASM_DL_HASH := dae69c310bedc02f07501adef71795d46e8c2a18

    # archive to extract binary from (distinct from NASM_DL in the case of RPM)
    NASM_DL_ARCHIVE := nasm-osx.zip

    # binary to extract from archive
    NASM_DL_BIN = nasm-$(NASM_DL_VERSION)/nasm
endif
ifeq ($(PLATFORM),linux)
    NASM_DL := nasm-linux.rpm
    NASM_DL_PLATFORM := linux
    NASM_DL_EXT := -1.x86_64.rpm
    NASM_DL_HASH := 2bc231565485b9c41d7c217ffe0e26a9ed9e7635
    NASM_DL_ARCHIVE := nasm-linux.cpio  # generated from the RPM, see below
    NASM_DL_BIN := ./usr/bin/nasm
endif

download/$(NASM_DL): download
	curl "http://www.nasm.us/pub/nasm/releasebuilds/$(NASM_DL_VERSION)\
	/$(NASM_DL_PLATFORM)/nasm-$(NASM_DL_VERSION)$(NASM_DL_EXT)" -o $@
	test `git hash-object $@` = $(NASM_DL_HASH)

# The Linux binary version of NASM is distributed as an RPM.
# This is moderately annoying, but we can deal with it without adding any
# superfluous dependencies.
# The following code is adapted from:
# http://rpm5.org/cvs/fileview?f=rpm/scripts/rpm2cpio&v=1.6
%.cpio: %.rpm
	if test "$<" != "download/$(notdir $<)" ;\
	 then mv $< download/$(notdir $<); fi
	@echo "Generating $@ from download/$(notdir $<)..."
	@cd download; f=$(notdir $<); l=96; o=`expr $$l + 8`; set `od -j $$o -N 8 -t u1 $$f`; il=`expr 256 \* \( 256 \* \( 256 \* $$2 + $$3 \) + $$4 \) + $$5`; dl=`expr 256 \* \( 256 \* \( 256 \* $$6 + $$7 \) + $$8 \) + $$9`; z=`expr 8 + 16 \* $$il + $$dl`; o=`expr $$o + $$z + \( 8 - \( $$z \% 8 \) \) \% 8 + 8`; set `od -j $$o -N 8 -t u1 $$f`; il=`expr 256 \* \( 256 \* \( 256 \* $$2 + $$3 \) + $$4 \) + $$5`; dl=`expr 256 \* \( 256 \* \( 256 \* $$6 + $$7 \) + $$8 \) + $$9`; h=`expr 8 + 16 \* $$il + $$dl`; o=`expr $$o + $$h`; e="dd if=$$f ibs=$$o skip=1"; c=`($$e |file -) 2>/dev/null`; if echo $$c | grep -q gzip; then d=gunzip; elif echo $$c | grep -q bzip2; then d=bunzip2; elif echo $$c | grep -q xz; then d=unxz; elif echo $$c | grep -q cpio; then d=cat; else d=`which unlzma 2>/dev/null`; case "$$d" in /*) ;; *) d=`which lzmash 2>/dev/null`; case "$$d" in /*) d="lzmash -d -c" ;; *) d=cat ;; esac ;; esac; fi; $$e 2>/dev/null | $$d > $(notdir $@)

nasm: download/$(NASM_DL_ARCHIVE)
	cd download \
	&& cpio -id --quiet $(NASM_DL_BIN) < $(NASM_DL_ARCHIVE) \
	&& mv $(NASM_DL_BIN) ../nasm \
	&& rmdir -p $(dir $(subst ./,,$(NASM_DL_BIN)))
	ls -l nasm
	./nasm -v
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Cleaning up.
.PHONY: distclean cleandl cleandmg cleantar

clean:
	rm -rf *.bin

cleandl:
	rm -rf download

distclean: cleandl clean
	rm -rf nasm *.dep
#-------------------------------------------------------------------------------
