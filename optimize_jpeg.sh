#!/bin/bash

INPUT_PATH=$1
QUALITY=$2


#set defaults
if [ "$QUALITY" == '' ]; then
	QUALITY=90
fi

DESTINATION_PATH="/cygdrive/e/tmp/image-output/$INPUT_PATH.q$QUALITY.jpg"
DESTINATION_DIR=$(dirname "$DESTINATION_PATH")
DESTINATION_FILENAME=$(basename "$DESTINATION_PATH")
INPUT_FILENAME=$(basename "$INPUT_PATH")
TMP_PATH=/tmp/$INPUT_FILENAME
TMP_DIR=/tmp/
TMP_DIR_WIN="s:\tmp"
UUID=`uuidgen`

if [ "$UUID" == '' ]; then
    echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** FATAL ERROR: Cannot get valid UUID"
    exit 255
fi


REGEX_PATTERN='[.]q[0-9]{2}[.]jpg$'
if [[ "$INPUT_PATH" =~ $REGEX_PATTERN ]]
then
	echo "---------------------------------------------------------------------------------"
	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** Input file $INPUT_PATH is already converted, skipping."
	exit 
fi

if [ ! -f "$DESTINATION_PATH" ]; then

	
	echo -n cygpath -w \"$INPUT_PATH\" > /tmp/command.$UUID.sh
	INPUT_PATH_WIN=`/tmp/command.$UUID.sh`
	#echo INPUT_WIN = $INPUT_WIN

	echo -n cygpath -w \"$DESTINATION_PATH\" > /tmp/command.$UUID.sh
	DESTINATION_PATH_WIN=`/tmp/command.$UUID.sh`
	#echo OUTPUT_WIN = $OUTPUT_WIN
	
	echo -n cygpath -w \"$TMP_PATH\" > /tmp/command.$UUID.sh
	TMP_PATH_WIN=`/tmp/command.$UUID.sh`
	#echo OUTPUT_TMP_WIN = $OUTPUT_TMP_WIN
	
	unlink /tmp/command.$UUID.sh
	EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** FATAL ERROR: cannot unlink /tmp/command.$UUID.sh"
		exit 255
	fi

	echo "---------------------------------------------------------------------------------"
	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** Converting $INPUT_PATH_WIN to $DESTINATION_PATH_WIN"
	

	#exit 255

	#encode
#	nice -n 20 jpegoptim.exe --verbose --preserve --threshold=10 --strip-none --max=$QUALITY "$INPUT_PATH_WIN" --dest="$TMP_DIR_WIN"
#	nice -n 20 jpegoptim.exe --verbose --preserve --threshold=2 --strip-none --max=$QUALITY "$INPUT_PATH_WIN" --dest="$TMP_DIR_WIN"
	nice -n 20 jpegoptim.exe --verbose --preserve --strip-none --max=$QUALITY "$INPUT_PATH_WIN" --dest="$TMP_DIR_WIN"

	EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** FATAL ERROR: exit code is $EXITCODE, which means an error for file '$INPUT_PATH_WIN'"
		unlink $TMP_PATH
		exit 255
	fi		
	
	mkdir -p "$DESTINATION_DIR"
	EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** FATAL ERROR: Cannot create directory $DESTINATION_DIR"
		exit 255
	fi
	
	mv "$TMP_PATH" "$DESTINATION_PATH"
	EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** FATAL ERROR: Cannot move '$TMP_PATH' to '$DESTINATION_PATH'"
		exit 255
	fi

	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** SUCCESS, conversion completed."
	
else

	echo "---------------------------------------------------------------------------------"
	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** Output file exists, skipping $INPUT_PATH"
	
fi

# sleep 3
