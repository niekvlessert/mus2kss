#!/bin/bash
rm -rf titles.csv

function process_file () {
	EXTENSION=$1
	
	for file in *.$EXTENSION; do
		echo $file
		dd skip=0xe2 count=0x32 if=$file of=$file.txt bs=1 2> /dev/null
		echo ${file}.txt | cut -f1-2 -d"." | tr -d $'\n' >> titles.csv
		echo -n "," >> titles.csv
		cat ${file}.txt >> titles.csv
		echo >> titles.csv
		rm ${file}.txt
	done
}

process_file MWM
process_file mwm 

echo
echo "Done, have a look at titles.csv..."
