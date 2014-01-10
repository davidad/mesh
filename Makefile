# Makefile for MESH ( http://mesh.is/ )
# (c) 2014 David Dalrymple
# See LICENSE for your rights to this software and README.md for instructions.

#-------------------------------------------------------------------------------
# Setting variables
VERSION ?= 0.0.1

# GNU Make will see all files in these directories as if they were top-level.
VPATH = download dmg_build

# Detect OS.
UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
	PLATFORM := darwin
endif
ifeq ($(UNAME),Linux)
	PLATFORM := linux
endif
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Default rule. Intended to build a mesh binary for the current platform.
mesh: mesh-$(VERSION)-$(PLATFORM)
	cp -f $< $@
mesh-$(VERSION)-%: nasm
	touch $@
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Packaging rules.
.PHONY: dmg
dmg: mesh-$(VERSION).dmg ;
ifeq ($(PLATFORM),darwin)
dmg_build/img: dmg_build/img/Mesh.app/Contents/MacOS/mesh
dmg_build/img: dmg_build/img/Mesh.app/Contents/Info.plist
dmg_build/img/Mesh.app/Contents/MacOS/mesh: mesh-$(VERSION)-darwin
	mkdir -p $(dir $@)
	cp -f $< $@
dmg_build/img/Mesh.app/Contents/Info.plist: Info.plist
	mkdir -p $(dir $@)
	cp -f $< $@

dmg_build/icn.rsrc: png/icon.png
	sips -i $<
	DeRez -only icns $< > $@

# DMG build process: create a tmp.dmg file, mount it, copy our new files to it,
# set attributes, unmount it, more attributes, and finally, compress it.
mesh-$(VERSION).dmg: dmg_build/img dmg_build/params.applescript icn.rsrc
	-hdiutil detach -force\
	 `hdiutil info | grep Mesh | awk '{print $$1}'`
	rm -f dmg_build/tmp.dmg
	az=`du -sm $< | awk '{ print $$1 }'` && dz=$$( expr $$az + 20 )\
	 && hdiutil create -srcfolder dmg_build/img -volname "Mesh"\
	 -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size $${dz}m\
	 dmg_build/tmp.dmg
	mkdir -p dmg_build/Mesh
	hdiutil attach dmg_build/tmp.dmg -readwrite -noverify -noautoopen\
	 -mountpoint dmg_build/Mesh
	mkdir -p dmg_build/Mesh/.bg
	cp png/dmg_background.png dmg_build/Mesh/.bg/bg.png
	cp png/volume_icons.icns dmg_build/Mesh/.VolumeIcon.icns
	SetFile -c icnC dmg_build/Mesh/.VolumeIcon.icns
	cd dmg_build/Mesh && ln -s /Applications ' '
	Rez -append dmg_build/icn.rsrc -o $$'dmg_build/Mesh/Mesh.app/Icon\r'
	SetFile -a V $$'dmg_build/Mesh/Mesh.app/Icon\r'
	SetFile -a C dmg_build/Mesh/Mesh.app
	osascript dmg_build/params.applescript Mesh # graphical formatting of dmg
	chmod -Rf go-w dmg_build/Mesh &> /dev/null || true
	bless --folder dmg_build/Mesh --openfolder dmg_build/Mesh # open on mount
	SetFile -a C dmg_build/Mesh                         # enable volume icon
	hdiutil detach -quiet -force\
	 `hdiutil info | grep Mesh | awk '{print $$1}'`
	rm -f $@
	hdiutil convert dmg_build/tmp.dmg -format UDZO -imagekey zlib-level=9 -o $@
	-Rez -append dmg_build/icn.rsrc -o $@
	SetFile -a C $@
	rm -rf dmg_build/tmp* dmg_build/Mesh
	ls -l $@

.PHONY: fresh_template
fresh_template: fresh_dmg template ;
fresh_dmg:
	mkdir -p dmg_build/template
	hdiutil create -fs HFSX -layout SPUD -size 40m -format UDRW -volname Mesh\
	 -srcfolder dmg_build/template dmg_build/template.dmg
	rmdir dmg_build/template
	ls -l dmg_build/template.dmg

.PHONY: template
template: dmg_build/template.dmg.gz ;
dmg_build/template.dmg.gz: template.dmg
	gzip -c9 $< > $@
	ls -l $@

dmg_build/template.dmg:
	cd dmg_build \
	&& gunzip template.dmg.gz
	ls -l $@

dmg_build/tmp.dmg: template.dmg ; cp $< $@
else
%.dmg: ;
	$(warning Ignoring OSX disk image target; currently supported only on OSX.)
endif

%.tar.gz: mesh-$(VERSION)-%.tar
	gzip -c -9 $< > $<.gz
	ls -l $<.gz
%.tar.xz: mesh-$(VERSION)-%.tar
	xz -c -6e $< > $<.xz
	ls -l $<.xz

mesh-$(VERSION)-src.tar: ;
	git diff --exit-code          # make sure that git is clean
	git diff --cached --exit-code #
	git archive --format=tar --prefix=mesh-$(VERSION)/ -o $@ HEAD

mesh-$(VERSION)-%.tar: mesh-$(VERSION)-%
	tar -cf $@ $<

.PHONY: dist dist-gz dist-xz
dist: dist-gz dist-xz dmg ;
dist-gz: src.tar.gz linux.tar.gz darwin.tar.gz ;
dist-xz: src.tar.xz linux.tar.xz darwin.tar.xz ;
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Download NASM.
NASM_DL_VERSION := 2.11
download: ; mkdir download

ifeq ($(PLATFORM),darwin)  # This means we are running on OSX.
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

cleandl:
	rm -rf download

cleandmg:
	rm -rf dmg_build/*.dmg dmg_build/Contents dmg_build/Mesh

cleantar:
	rm -rf *.tar

cleanball:
	rm -rf *.tar.*

distclean: cleandl cleandmg cleantar cleanball
	rm -rf nasm
	rm -rf mesh-*.*.*
#-------------------------------------------------------------------------------
