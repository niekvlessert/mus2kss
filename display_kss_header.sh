#!/bin/bash
echo Display KSS header settings in human readable format
echo By: niekniek 2017

files=$1
if [ -z "$files" ] || [ ! -f "$files" ]; then
	echo Usage:
	echo "$0 <kss files (wildcards are allowed)>"
	exit
fi

function displayHeader {
	echo -e "File:\t\t\t$file"
	echo -e "Type:\t\t\t$type"
	echo -e "Load address:\t\t0x$load"
	echo -e "Load size:\t\t0x$length"
	echo -e "Init address:\t\t0x$init"
	echo -e "Player address:\t\t0x$player_address"
	echo -e "Mapper offset:\t\t0x$mapper_offset"
	echo -e "Amount of pages:\t$mapper_pages"
	echo -e "Page size:\t\t$page_size"
	echo -e "Chips enabled:\t\t$textual_chips"
	echo -e "Vsync:\t\t\t$vsync"
	echo -e "RAM Mode:\t\t$ram_mode"
	if [ "$bool_extra_header" -eq "10" ]; then
		echo
		echo "Extra KSSX header at 0x10 enabled"
		echo
		echo -e "Offset to end of file:\t0x$extra_offset"
		echo -e "First track:\t\t0x$first_track"
		echo -e "Last track:\t\t0x$last_track"
		echo -e "PSG volume:\t\t0x$psg_volume"
		echo -e "SCC volume:\t\t0x$scc_volume"
		echo -e "FMPAC volume:\t\t0x$fmpac_volume"
		echo -e "MSX Audio volume:\t0x$msxaudio_volume"
	fi
	if [ $playlist -eq 1 ]; then
		echo
		echo "Playlist information in KSS file"
		echo
		echo -e "Amount of tracks:\t0x$playlist_amount_of_tracks"
		echo
		for (( c=0; c<0x$playlist_amount_of_tracks; c++ ))
		do
			echo -e "track id:\t\t0x${playlist_header:$skip:2}"
			#echo "type: ${playlist_header:$(($skip+2)):2}"
			echo -e "length (ms):\t\t0x${playlist_header:$(($skip+10)):2}${playlist_header:$(($skip+8)):2}${playlist_header:$(($skip+6)):2}${playlist_header:$(($skip+4)):2}"
			echo -e "fade (ms):\t\t0x${playlist_header:$(($skip+18)):2}${playlist_header:$(($skip+16)):2}${playlist_header:$(($skip+14)):2}${playlist_header:$(($skip+12)):2}"
			temp_var=$(echo ${playlist_header:$(($skip+20)):100})
			end_title=`awk -v var="$temp_var" 'BEGIN { print index(var, "00") }'`
			end_title=$(($end_title+1))
			titel=$(echo ${playlist_header:$(($skip+20)):$end_title} | xxd -r -p)
			echo -e "title:\t\t\t$titel"
			echo
			skip=$(($skip+$end_title+20))
		done
	fi
}

for file in "$@";
do
	kssx_found=0
	sega=0
	textual_chips=""
	page_size=""
	vsync="60Hz"
	ram_mode="disabled"
	playlist=0

	echo

	header=`xxd -ps "$file" | head -n 2 | tr -d "\n"`

	type=`echo ${header:0:8} | xxd -p -r`
	load=${header:10:2}${header:8:2}
	length=${header:14:2}${header:12:2}
	init=${header:18:2}${header:16:2}
	player_address=${header:22:2}${header:20:2}
	mapper_offset=${header:24:2}
	mapper_pages="0x${header:26:2}"
	if (( $mapper_pages > 0x82 )); then
		mapper_pages=$(($mapper_pages - 0x83))
		page_size="8kB"
	else
		page_size="16kB"
	fi
	#skip $0e
	chips="${header:30:2}"
	chips=$(echo $chips | tr /a-z/ /A-Z/)
	if [ "$type" == "KSCC" ]; then
		if (( 0x$chips == 0x0 )); then
			textual_chips="PSG SCC SCC+"
		else
			chips=$(echo "obase=2; ibase=16; $chips" | bc )
			chips=$(printf '%08d\n' "$chips")
			echo $chips
			if [ ${chips:6:1} -eq 1 ]; then
				sega=1
			else
				if [ ${chips:7:1} -eq 1 ]; then
					textual_chips="FMPAC"
				fi
				if [ ${chips:4:1} -eq 1 ]; then
					textual_chips="$textual_chips MSX-Audio"
				fi
			fi
		fi
	fi
	if [ "$type" == "KSSX" ]; then
		if (( 0x$chips == 0x0 )); then
			textual_chips="PSG SCC SCC+"
		else
			chips=$(echo "obase=2; ibase=16; $chips" | bc )
			chips=$(printf '%08d\n' "$chips")
			if [ ${chips:6:1} -eq 1 ]; then
				sega=1
			else
				if [ ${chips:7:1} -eq 1 ]; then
					textual_chips="FMPAC"
				fi
				if [ "${chips:3:2}" == "01" ]; then
					textual_chips="$textual_chips MSX-Audio"
				fi
				if [ "${chips:3:2}" == "10" ]; then
					textual_chips="$textual_chips Majutushi D/A"
				fi
				if [ "${chips:3:2}" == "11" ]; then
					textual_chips="$textual_chips MSX-Audio (stereo mode)"
				fi
				if [ ${chips:1:1} -eq 1 ]; then
					vsync="50Hz"
				fi
				if [ ${chips:5:1} -eq 1 ]; then
					ram_mode="enabled"
				fi
			fi
		fi
	fi
	textual_chips=$(echo $textual_chips | sed -e 's/^[ \t]*//')
	if [ "$type" == "KSCC" ]; then
		type="KSS"
		#Show KSCC header
		displayHeader
	fi
	if [ "$type" == "KSSX" ]; then
		#KSSX found, scan for extra header if it's enabled...
		kssx_found=1
		bool_extra_header=${header:28:2}
		if [ "$bool_extra_header" == "10" ]; then
			extra_offset=$(echo ${header:38:2}${header:36:2}${header:34:2}${header:32:2})
			extra_offset=`echo $extra_offset |sed 's/^0*//' | tr /a-z/ /A-Z/`
			extra_offset=$(echo "obase=16;ibase=16;$extra_offset + 10 + $bool_extra_header" | bc)
			first_track=${header:50:2}${header:48:2}
			last_track=${header:54:2}${header:52:2}
			psg_volume=${header:56:2}
			scc_volume=${header:58:2}
			fmpac_volume=${header:60:2}
			msxaudio_volume=${header:62:2}

			if (( 0x$extra_offset > 0 )); then
				playlist_header=$(xxd -ps -s 0x$extra_offset -l 4 $file)
				if [ "$playlist_header" == "494e464f" ]; then
					playlist=1
					playlist_header=$(xxd -ps -s 0x$extra_offset $file | tr -d "\n")
					playlist_amount_of_tracks=${playlist_header:18:2}${playlist_header:16:2}
					playlist_header=${playlist_header:32}
					skip=0
				fi
			fi
		fi
		displayHeader
	fi
done
