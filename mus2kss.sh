#!/bin/bash
echo FST Sound Tracker MUS to KSS converter
echo Made By: NYYRIKKI
echo Ported to OSX and Linux By: niekniek
echo
CHIP=$1
FILE=$2
KIT=$3
KIT2=`echo $KIT | sed 's/.$//'`
KIT2="${KIT2}2"
WORKDONE=0

if [ -z "$FILE" ] || [ ! -f "$FILE" ] || [ -z "$CHIP" ]; then
	echo Usage:
	echo "$0 <-f|-a> <mus_file> [sm1_file]"
	echo
	echo "-f for converting FMPAC data to KSS, -a to convert MSX Audio data. Add sm1 file if you want to include the drumkit, the sm2 file will be found"
	exit
fi


if [ "$CHIP" == "-a" ]; then
	echo "MSX Audio data being exported"
	if [ -n "$KIT" ] || [ -f "$KIT" ]; then
		echo "Drumkit is included"
		bincut2 -o 1.tmp -l 10 -p 0:4B,53,53,58,00,00,FF,FF,10,C0,38,00,00,00,00,08 $FILE
		bincut2 -o 2.tmp -s 7 -l 4000 $KIT
		bincut2 -o 3.tmp -s 7 -l 4000 $KIT2

		bincut2 -o 4.tmp -s 7 -p C:0 -p 10:21,00,C0,11,00,D0,01,96,08,ED,B0,AF,32,48,D8,CD,03,D0,3E,40,32,48,D8,CD FST2.BIN
		bincut2 -o 5.tmp -p 28:03,D0,21,00,00,11,01,00,01,FF,3F,36,C9,ED,B0,21,6D,D0,11,20,00,01,06,00 4.tmp
		bincut2 -o 4.tmp -p 40:ED,B0,3E,C3,21,9A,FD,32,38,00,22,39,00,21,00,80,11,00,40,D5,C1,ED,B0,3E 5.tmp
		bincut2 -o 5.tmp -p 58:40,32,A9,D0,32,C8,D0,3E,7F,32,AC,D0,32,E8,D0,CD,A1,D0,C3,06,D0,7C,92,C0,7D,93,C9 4.tmp
		bincut2 -o 4.tmp -s 7 -l 4000 $FILE

		cat 1.tmp 2.tmp 3.tmp 4.tmp 5.tmp > $FILE.kss
	else
		echo "No Drumkit"
		bincut2 -o 1.tmp -l 10 -p 0:4B,53,53,58,00,40,FF,FF,10,80,38,00,00,00,00,08 $FILE
		bincut2 -o 2.tmp -s 7 -l 4000 $FILE
		bincut2 -o 3.tmp -s 7 -p C:0 -p A3:7F -p 10:21,00,80,11,00,D0,01,96,08,ED,B0,21,47,D0,11,20 FST2.BIN
		bincut2 -o 4.tmp -p 20:00,01,06,00,ED,B0,3E,C3,21,9A,FD,32,38,00,22,39 3.tmp
		bincut2 -o 3.tmp -p 30:00,3E,40,32,A9,D0,32,C8,D0,3E,7F,32,AC,D0,32,E8,D0,CD,A1,D0,C3,06,D0,7C,92,C0,7D,93,C9 4.tmp
		cat 1.tmp 2.tmp 3.tmp 4.tmp > $FILE.kss
	fi
	WORKDONE=1
fi
if [ "$CHIP" == "-f" ]; then
	echo "FMPAC data being exported"
	bincut2 -o 1.tmp -l 10 -p 0:4B,53,53,58,00,40,FF,FF,10,80,38,00,00,00,00,01 $FILE
	bincut2 -o 2.tmp -s 7 -l 4000 $FILE
	bincut2 -o 3.tmp -s 7 -p C:1 -p A3:7F -p 10:21,00,80,11,00,D0,01,96,08,ED,B0,21,47,D0,11,20 FST2.BIN
	bincut2 -o 4.tmp -p 20:00,01,06,00,ED,B0,3E,C3,21,9A,FD,32,38,00,22,39 3.tmp
	bincut2 -o 3.tmp -p 30:00,3E,40,32,A9,D0,32,C8,D0,3E,7F,32,AC,D0,32,E8,D0,CD,A1,D0,C3,06,D0,7C,92,C0,7D,93,C9 4.tmp
	cat 1.tmp 2.tmp 3.tmp >$FILE.kss
	WORKDONE=1
fi

if [ $WORKDONE -eq 0 ]; then
	echo "Something went wrong..."
fi

rm *.tmp
