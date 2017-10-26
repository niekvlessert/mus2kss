# mus2kss

FST Sound Tracker MUS to KSS converter Made By: NYYRIKKI (2002),
Ported for OSX/Linux niekniek (2017)
----------------------------------------------------------------------

These shell scripts will convert FST Sound Tracker MUS files to KSS format.

Usage:
mus2kss.sh [-a/-f] [filename.mus] <drumkit.sm1>

-f for converting FMPAC data to KSS, -a to convert MSX Audio data. Add sm1 file if you want to include the drumkit, the sm2 file will be found

You will need to compile bincut2.c for your platform.
Use gcc bincut2.c -o bincut2

It's probably best to copy FST2.bin to the directory where the music is.
Copy bincut2 and the .sh file to /usr/local/bin for example.
Then go the music directory and just follow Usage.

Files in this package:
mus2kss.sh	Use this to convert the MUS files.
FST2.BIN	Original FST Sound Tracker 2.0 play routine for BASIC.
bincut2.c	bincut2.1 for Windows made by Mamiya

			    ,_____.
		    _=_=_=_=!_MSX_!=_=_=_=_=_=_=_=_,
		   ! A1GT ~--- - I  ( o o o o o o )i
		  /--------------------------------`,
		 / .::::::::::::::::::::::;::;	::::.,
		/ :::.:.:.:::____________:::::!.  -=- `,
		~======================================
		                NYYRIKKI

