#!/bin/bash

SELF=`basename "$0"`
DIR=$(dirname "$0")
DATE=`date +%s`

#/bin/find . -iname "*.mov" -exec $DIR/encode.sh {} \; | tee $SELF.`date +%s`.log
#/bin/find . -iname "*.mov" -print0 | xargs -0L1 sh -c "$DIR/encode.sh \$0" | tee $SELF.`date +%s`.log
#/bin/find . -iname "*.mov" -print0 | xargs -0L1 sh -c "$DIR/params.sh \$0"

#/bin/find . -iname "*.mov" -iname "*.mp4" -print0 | xargs -0L1 sh -c "$DIR/encode.sh \"\$0\""
/bin/find . -iregex '.*\(mp4\|mov\|ts\)$' -print0 | xargs -0L1 sh -c "$DIR/encode.sh \"\$0\" $1 $2"

