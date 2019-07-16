#!/bin/bash

#ENCODER=264
INPUT=$1
CRF=$2
ENCODER=$3
PRESET=slower

#set defaults
if [[ "$CRF" == '' ]]; then
	CRF=23
fi

if [[ "$ENCODER" == '' ]]; then
	ENCODER=264
fi

OUTPUT="/cygdrive/s/tmp/ffmpeg-output/$INPUT.$ENCODER.$CRF.mp4"
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
	-c:v libx$ENCODER \
	-preset $PRESET \
	-x$ENCODER-params "crf=$CRF" \
	-c:a aac \
	-strict experimental \
	-b:a 128k \
	-f mp4 \
	-max_muxing_queue_size 1024 \
	"$OUTPUT_TMP_WIN"
	
#	#encode and force FPS div by 4, no audio
#	nice -n 20 /cygdrive/c/Program\ Files/ffmpeg/bin/ffmpeg.exe \
#	-y -i "$INPUT_WIN" \
#	-vf "setpts=4*PTS" \
#	-an \
#	-c:v libx${ENCODER} \
#	-preset ${PRESET} \
#	-x${ENCODER}-params "crf=$CRF" \
#	-strict experimental \
#	-f mp4 \
#	-max_muxing_queue_size 1024 \
#	"$OUTPUT_TMP_WIN"

#	-filter_complex "[0:v]setpts=4*PTS[v];[0:a]atempo=0.5,atempo=0.5[a]" -map "[v]" -map "[a]" \
#	-c:a aac \
#	-b:a 128k \

#	-vf "setpts=4*PTS" \
#	-an \

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
