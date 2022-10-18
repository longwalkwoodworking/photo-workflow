# Copyright © 2022 Eric Diven

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

# Parameters for image conversion are in a separate file so that changes to the
# build system don't result in remaking every image.
include jpeg-params.mk

# Anything that needs to be defined to run on your local system
include local.mk

XCF_EXPORT_SCM := xcf_export.scm.m4
XCF_EXPORT_UP_TO_DATE := xcf_export.uptodate

SRC_DIR := src-pictures
WEB_DIR := web-pictures
SMALL_DIR := small-pictures

# all directories are assumed to be image directories
IMAGE_DIRS := $(sort $(shell find . -name ".git*" -prune -o -type d -depth 1 -print))

SRC_IMAGE_DIRS := $(IMAGE_DIRS:%=%/$(SRC_DIR))
WEB_IMAGE_DIRS := $(IMAGE_DIRS:%=%/$(WEB_DIR))
SMALL_IMAGE_DIRS := $(IMAGE_DIRS:%=%/$(SMALL_DIR))

# source images had better be direct children of $(SRC_DIR). If not, convert
# will fail when there's no destination directory for them. If that happens,
# update the Makefile or move the pictures :-)
SRC_IMAGES := $(shell find $(SRC_IMAGE_DIRS) -type f \( -iname *.jpg -or -iname *.jpeg \) )
WEB_IMAGES := $(subst $(SRC_DIR),$(WEB_DIR),$(SRC_IMAGES))
SMALL_IMAGES := $(subst $(SRC_DIR),$(SMALL_DIR),$(SRC_IMAGES))

SRC_XCF := $(shell find $(SRC_IMAGE_DIRS) -type f -iname *.xcf)

.PHONY: all
all: $(XCF_EXPORT_UP_TO_DATE) $(WEB_IMAGES) $(SMALL_IMAGES)

# Am I that confident in the mess below? No.
.PHONY: force-xcf
force-xcf: clean-xcf-uptodate $(XCF_EXPORT_UP_TO_DATE)

.PHONY: clean-xcf-uptodate
clean-xcf-uptodate:
	-rm -f $(XCF_EXPORT_UP_TO_DATE)

# Skip exporting the xcf files if you remember to make this target after
# modifying the Makefile.
.PHONY: skip-xcf
skip-xcf:
	touch $(XCF_EXPORT_UP_TO_DATE)

.PHONY: clean
clean:
	-rm pattern_rules.mk

$(WEB_IMAGE_DIRS)::
	@-mkdir $@ >/dev/null 2>&1

$(SMALL_IMAGE_DIRS)::
	@-mkdir $@ >/dev/null 2>&1

# Several points:
# 1) This is clearly a hot mess.
# 2) This batches everything together and runs the conversion in one gimp
# process. gimp -i -b "(gimp-quit TRUE)" takes 2.5 seconds on my (old) machine.
# I can't throw enough cores at the conversions to break even on the repeated
# startup time, so I'm batching them. Users with many cores and much RAM will
# likely dislike this solution. 
# 3) Obviously a pattern rule would be vastly cleaner and as an added bonus
# allow for parallel processing.
$(XCF_EXPORT_UP_TO_DATE): $(XCF_EXPORT_SCM) $(SRC_XCF) Makefile
	set -o pipefail
	m4 -D XCF_FILES="$$(echo $(filter-out Makefile,$(filter-out $<,$?)) \
		| sed 's/ /\n/g' \
		| sed 's/^\(.+\)$$/\"\1\"/')" $< \
		| tee /dev/fd/2 \
		| $(GIMP) -i -b -
	touch $@

# Depend on current directory to pick up new photo directories. This will
# almost certainly result in pattern_rules.mk being remade more often than
# necessary, but it isn't a dependecy of anything so the excess work will stop
# there.
pattern_rules.mk: pattern_rules.sh Makefile .
	$(SHELL) $< $(IMAGE_DIRS) >$@

include pattern_rules.mk
