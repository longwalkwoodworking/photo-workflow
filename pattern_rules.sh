#!/bin/zsh
# Copyright © 2022 Eric Diven

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

while [[ $# -gt 0 ]]; do
	cat <<END
$1/web-pictures/%: $1/src-pictures/% jpeg-params.mk | $1/web-pictures
	convert $< \$(WEB_FLAGS) \$@

$1/small-pictures/%: $1/src-pictures/% jpeg-params.mk | $1/small-pictures
	convert $< \$(SMALL_FLAGS) \$@

END
	shift
	done
