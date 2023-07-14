#!/bin/bash

set -e

#ENCODER=264
INPUT=$1
CRF=$2 # lower values = better quality
ENCODER=$3
PRESET=slow

#set defaults
if [[ "$CRF" == '' ]]; then
	CRF=28
fi

if [[ "$ENCODER" == '' ]]; then
	ENCODER=265
fi

OUTPUT="/cygdrive/c/tmp/ffmpeg-output/$INPUT.$ENCODER.$CRF.mp4"
DIR=$(dirname "$OUTPUT")
OUTPUT_FILE=$(basename "$OUTPUT")
OUTPUT_TMP=/tmp/${OUTPUT_FILE}

REGEX_PATTERN='[.](264|265)[.][0-9]{2}[.]mp4$'
if [[ "$INPUT" =~ $REGEX_PATTERN ]]
then
	echo "---------------------------------------------------------------------------------"
	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** Input file $INPUT is already converted, skipping."
	exit 
fi

if [[ ! -f "$OUTPUT" ]]; then

	
	echo -n cygpath -w \"${INPUT}\" > /tmp/command.sh
	chmod +x /tmp/command.sh
	INPUT_WIN=`/tmp/command.sh`
	#echo INPUT_WIN = $INPUT_WIN

	echo -n cygpath -w \"${OUTPUT}\" > /tmp/command.sh
	OUTPUT_WIN=`/tmp/command.sh`
	#echo OUTPUT_WIN = $OUTPUT_WIN
	
	echo -n cygpath -w \"${OUTPUT_TMP}\" > /tmp/command.sh
	OUTPUT_TMP_WIN=`/tmp/command.sh`
	#echo OUTPUT_TMP_WIN = $OUTPUT_TMP_WIN
	
	unlink /tmp/command.sh
	#exit
	
	echo "---------------------------------------------------------------------------------"
	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** Converting $INPUT_WIN to $OUTPUT_WIN"
	
    # x265
	#nice -n 20 /cygdrive/c/Program\ Files/ffmpeg/bin/ffmpeg.exe -y -i "$INPUT_WIN" -c:v libx265 -preset $PRESET -x265-params crf=$CRF -c:a aac -strict experimental -b:a 128k -f mp4 "$OUTPUT_TMP_WIN"
	
	# x264
	#nice -n 20 /cygdrive/c/Program\ Files/ffmpeg/bin/ffmpeg.exe -y -i "$INPUT_WIN" -c:v libx264 -preset $PRESET -x264-params crf=$CRF -c:a aac -strict experimental -b:a 128k -f mp4 "$OUTPUT_TMP_WIN"
	
	#encode
	nice -n 20 /cygdrive/c/Program\ Files/ffmpeg/bin/ffmpeg.exe \
	-y -i "$INPUT_WIN" \
	-c:v libx${ENCODER} \
	-preset ${PRESET} \
	-x${ENCODER}-params "crf=$CRF" \
	-pix_fmt yuv420p10le \
	-c:a aac \
	-strict experimental \
	-b:a 128k \
	-f mp4 \
	"$OUTPUT_TMP_WIN"

#	#encode and force FPS/4, no sound
#	nice -n 20 /cygdrive/c/Program\ Files/ffmpeg/bin/ffmpeg.exe \
#	-y -i "$INPUT_WIN" \
#	-vf "setpts=4*PTS" \
#	-an \
#	-c:v libx$ENCODER \
#	-preset $PRESET \
#	-x$ENCODER-params "crf=$CRF" \
#	-pix_fmt yuv420p10le \
#	-strict experimental \
#	-f mp4 \
#	"$OUTPUT_TMP_WIN"

#	-vf "setpts=4*PTS" \

#	-filter_complex "[0:v]setpts=4*PTS[v];[0:a]atempo=4[a]" -map "[v]" -map "[a]" \
#	-c:a aac \
#	-b:a 128k \

	
	#check ffmpeg exit code
	EXITCODE=$?
	if [[ ${EXITCODE} -ne 0 ]]; then
		echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** FATAL ERROR: ffmpeg exit code is $EXITCODE, which means an error for file '$INPUT_WIN'"
		unlink ${OUTPUT_TMP}
		exit 255
	fi		
	
	mkdir -p "$DIR"
	EXITCODE=$?
	if [[ ${EXITCODE} -ne 0 ]]; then
		echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** FATAL ERROR: Cannot create directory $DIR"
		exit 255
	fi
	
	mv "$OUTPUT_TMP" "$OUTPUT"
	EXITCODE=$?
	if [[ ${EXITCODE} -ne 0 ]]; then
		echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** FATAL ERROR: Cannot move '$OUTPUT_TMP' to '$OUTPUT'"
		exit 255
	fi

	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** SUCCESS, conversion completed."
	
else

	echo "---------------------------------------------------------------------------------"
	echo "[`date \"+%Y-%m-%d %H:%M:%S\"`] *** Output file exists, skipping $INPUT"
	
fi

# sleep 3
