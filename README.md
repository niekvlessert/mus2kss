# mus2kss

FST Sound Tracker MUS to KSS converter 
----------------------------------------------------------------------
Initially Made By: NYYRIKKI (2002), modified for OSX/Linux niekniek (2017)

This project started with a .BAT file modified to a .SH file. The script will convert a single FST Sound Tracker MUS file to KSS format.

After that it evolved to an improved version of the conversion script and then to asm files for Sjasm that create a single KSS file from a collection of FST tracks. The KSS file will play all tracks for MSX Audio first, then for FMPAC.

Information about the asm files will follow, you can look at the source for now.

Shell script usage:
mus2kss.sh [-a/-f] [filename.mus] <drumkit.sm1>

-f for converting FMPAC data to KSS, -a to convert MSX Audio data. Add sm1 file if you want to include the drumkit, the sm2 file will be found automatically.

You will need to compile bincut2.c for your platform, it's required.
Use gcc bincut2.c -o bincut2

It's probably best to copy FST2.bin to the directory where the music is.
Copy bincut2 and the .sh file to /usr/local/bin for example.
Then go the music directory and just follow Usage.

NYYRIKKI's original logo is nice so I left it in. :)

			    ,_____.
		    _=_=_=_=!_MSX_!=_=_=_=_=_=_=_=_,
		   ! A1GT ~--- - I  ( o o o o o o )i
		  /--------------------------------`,
		 / .::::::::::::::::::::::;::;	::::.,
		/ :::.:.:.:::____________:::::!.  -=- `,
		~======================================
		                NYYRIKKI

