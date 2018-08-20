#!/bin/bash

SELF=`basename "$0"`
DIR=$(dirname "$0")
DATE=`date +%s`

/bin/find . -iregex '.*[.]\(jpg\|jpeg\)$' -print0 | xargs -0L1 sh -c "$DIR/optimize_jpeg.sh \"\$0\" $1 $2"

