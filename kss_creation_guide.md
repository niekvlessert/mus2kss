# KSS Creation Guide

By Niek Vlessert 2017

Many thanks to NYYRIKKI and BiFi.

Preface
=======

It's difficult to find information about the KSS format on the internet. One can find tiny specifications from KSS and KSSX which doesn't tell non-Z80 assembly programmers a lot.
This documents tries not only to give you relevant information but also tries to explain how KSS files are created.
It took me quite a while to understand the techniques used and many thanks go to NYYRIKKI, who gave me a lot of insights and information.

Intended Audience
=================

You don't have to know anything about Z80 assembly programming to understand this text, I myself am a novice Z80 programmer, but if you want to be able to get music from games into KSS files you need to become an expert, simple as that. You do need to know your way around in the shell on a Linux box or an OSX machine, and you'll need basic programming knowledge in some language.

Software
========

There are two libraries available for playing KSS files; Libkss (by Okaxaki) and LibGME (by Blargg). Libkss is the better choice, because:

- Libkss supports MSX Audio ADPCM
- Libkss supports the KSSX format
- GME has emulation bugs, so some SCC tunes start ok, but eventually some channels will start to behave weird

With those libraries players can be build. The support for the KSS format is not in a lot of players, but players trying to support a lot of formats have support most of the time. Be careful though, use a player using Libkss. If you want to be sure, use Audio Overload, it'll probably work on your machine and uses Libkss. For Android you can use ViGaMuP.

Libkss supports the following chips: PSG, FMPAC (MSX Music, OPLL, YM2413), MSX Audio (OPL2, Y8950), SCC and SCC+. It doesn't support Moonsound (OPL4, YMF278B).

Libkss is programmed in C, but Okaxaki has made a Javascript version called MSXplay.js, which uses Emscripten, which allows using the library in a browser, including a player.

Okaxaki also created convertors; from MSX music files to KSS format, like mbm2kss (Moonblaster), bgm2kss, mgs2kss (AIN), mpk2kss and opx2kss. Also the other way around; kss2vgm. It's all on Github.

This guide comes with mus2kss, a convertor for FAC Soundtracker 2 music. It was initially based on NYYRIKKI's work, but with tips from him and trying a lot it's now also a collection of asm files which create KSS files. More on that later.

Tools
=====

When working with KSS files you'd better have a Z80 assembler/disassembler available. Xxd is also a useful tool. It's possible to create KSS files by hand by putting hex codes in files but compiling them from assembler code is much more convenient. Sjasm is a good choice for an assembler, it'll run on most platforms, and the demo asm files are for this assembler.

The KSS format
==============

The KSS format is mostly used for MSX music, however it can also be used for music from other platforms running on a Z80 processor and using one of the soundchips from above, for example the Sega Game Gear.

Because that is what Libkss is; a Z80 and soundchip emulator, it's *not* a computer emulator. This basically means that a KSS file must at least contain a player engine programmed for the Z80 and music data. But the usage from that player should be adapted for use with the KSS player.

You can't just input a MSX program in Libkss, because Libkss won't support all the instructions used, for example anything concerning displaying things won't work, it'll be simply ignored. If the code depends on values to be returned from the VDP the program may even end up in an infinite loop. The trick is to change the code so this won't happen. Another approach is to just extract the player and music.
Both things are not easy; you must have a very good knowledge of Z80 programming to do so. The easiest approach is probably taking an existing player with music and go from there. If I'm ever capable of extracting music & players from games I will add tips to this guide.

Every KSS file should have a file header, at least 0x10 bytes for the KSS format or 0x1f bytes for the KSS extended format KSSX. The spec will give you information, but I found it difficult to understand. 

The spec contains more then just the header, but for the sake of readability I'll skip that for now. I will probably write a new spec document soon with less surrounding information, but enough to better understand things. I can also document some undocumented things Libkss does in there. 

So first the KSS header!

|Position|Information|
|--------|-----------|
|0x0-0x3| The first 4 bytes should contain KSCC for the KSS format or KSSX for the KSSX format. This header decides how Libkss will interpret the file.|
|0x4-0x5| The next 2 bytes should contain the Load address. Be careful though; everything is little Endian (Z80...), so address 8000 must be in the header like this: 0080. The load address defines the Z80 memory address from the first byte of the KSS file. This is the location without the header. So be careful when trying to find code in a KSS file; when using a disassembler substract the header size to make the code start at #0000. So z80dasm -a -t -g -0x10 <kssfile>. You may also try to set the offset at the load address, for #d000 this would mean z80dasm -a -t -g 0xcff0, however this most likely won't work since the filesize will exceed #ffff and that won't be accepted by the disassemblers I tried.|
|0x6-0x7|The next 2 bytes contain how much data should be loaded; that's all the bytes in the file minus the header or if you're lazy insert ffff. At least when not using memory mapping this is allowed, more on that later.|
|0x8-0x9|Next is the Init address in 2 bytes. Now things get interesting. The Init address is just an address in the KSS file that should contain the z80 code that initialises the player. The actual code of the player engine expects to be running on a certain address in memory however, it depends on the player where that is. This has to be exactly right. The example later on will show you. The initialisation code is started with every track change, not just once! Another detail is that the accumulator in the Z80 emulation will contain the current track number, so the Z80 code can use this variable to select that certain track to be played.|
|0xa-0xb|Then the player address in 2 bytes. This is the address that is called 60 times a second (by default), like the computer running the player would be doing. That's also a certain address you'd have to know.|
|0xc-0xd| These two bytes do the banking. The Z80 is an 8 bit CPU, so it can only address 64kB, to access other areas memory mapping can be used. More on that later.|
|0xe| Must be skipped.|
|0xf| This byte is important again; this defines the chips used in the track and some other settings. The spec tries to tell you it supports Sega hardware and MSX hardware. It's efficient, because a lot of settings are crammed into 1 byte from the header (and only half the byte is currently used!), but it's hard to read. Bit 1 is important; if you set that to 1, it'll mean you're using SN76489. That was never used on MSX, so it has to mean Sega hardware. This setting changes the meaning of bits 0, 2 and 3. When bit 1 is enabled, bit 0 means enable FMUNIT. Enabling bit 2 means Game Gear stereo. Bit 3 means RAM mode, which changes the way memory mapping behaves, more on that later. However if you set bit 1 to 0, bit 0 means enable FMPAC, enabling bit 2 means RAM mode and bit 3 to 1 enables MSX Audio. SCC is also supported, it's enabled by default.|
	
Now for the KSSX Header.

|Position|Information|
|--------|-----------|
| 0x0-0x3|Now this must be KSSX|
| 0x4-0xd|Same as KSS format|
| 0xe|In here you can put 0 or 10. When putting 0 in here the header size remains the same, if you put 10 in there, the header will be expanded with 0x10 bytes. I don't know why the whole byte is used for this, could have just taken a bit from 0xf for this...|
| 0xf|Things have changed a little bit in this byte. Bit 1 is still the important one, it still decides about the Sega or MSX 'mode'. The spec says however bit 0 is not dependent on bit 1 anymore, it'll just enable/disable MSX Music. If bit 1 is 0, bit 2 means enable/disable RAM mode. If bit 1 is 1 it means GG Stereo. Bit 3 and 4 enable/disable an extra device. 00 is nothing, 01 is MSX Audio, 10 is Majutushi D/A (never heard of that), 11 MSX Audio (Stereo). Bit 5 and 7 are not used. Bit 6 is however, it regulates the VSYNC frequency. Japanese software normally runs at 60 Hz, European software uses both. If the default 60 Hz is used everything music is running 20% faster, so European music goes too fast if composed for 50 Hz. 0 means 60 Hz, 1 50 Hz.|

Now we are at the extra header when you've set 0xe on 10.

|Position|Information|
|--------|-----------|
|0x10-0x13|Offset to end of file according to the spec. Actually it should have offset to the end off the KSS data, that would have made more sense. More on this later.|
|0x14-0x17|Should be 0|
|0x18-0x19|Number of first song|
|0x1a-0x1b|Number of last song. Use in conjuction with first song. With this you can avoid the player offering all 255 tracks always. I noticed Audio Overload thinks the KSS file contains 1 track when both first and last song are 0.|
|0x1c| PSG/SNG Volume|
|0x1d| SCC Volume|
|0x1e| MSX-MUSIC/FM-Unit Volume|
|0x1f| MSX Audio Volume|

The volume fields work as follows:
$81(MIN)...$E0(x1/4)...$F0(x1/2)...$00(x1)...$10(x2)...$10(x2)...$20(x4)..$7F(MAX), so 0.375dB/step.

You could use z80dasm to see the code in the KSS file, but when the header is needed xxd output is easier to read: xxd <kssfile> | head -n 1. Remember little endian. If you need the plain hex to input into an online disassembler you can try the -ps flag.

Be careful when dissambling MSX files; they might have a 7 byte header. BIN files must have the header to be able to use them on a MSX, but for example FST files have them as well.

A closer look at a KSS file
===========================

As an example I'll explain a KSS file that'll play a single FST 2.0 track. It can be created using the single_track.asm file. But just take it for granted for now, it's more about the information then creating your own file.

First let's have a look at the header:
```
xxd single_mus.kss | head -n1
00000000: 4b53 4343 0000 ff9f f908 76d1 0000 0001  KSCC......v.....
```
You can see the start address is 0000, the length is 9fff, the init address is 08f9, the interrupt routine is at 1d76, no memory mapping and it uses FMPAC.

The init address is important; so let's have a look there.

```
z80dasm -a -t -g -0x10 single_mus.kss | grep -A 14 ";08f9"
	ld hl,00000h		;08f9	21 00 00 	! . . 
	ld de,0d000h		;08fc	11 00 d0 	. . . 
	ld bc,00918h		;08ff	01 18 09 	. . . 
	ldir		;0902	ed b0 	. . 
	ld hl,0d912h		;0904	21 12 d9 	! . . 
	ld de,00020h		;0907	11 20 00 	.   . 
	ld bc,00006h		;090a	01 06 00 	. . . 
	ldir		;090d	ed b0 	. . 
	jp 0d006h		;090f	c3 06 d0 	. . . 
	ld a,h			;0912	7c 	| 
	sub d			;0913	92 	. 
	ret nz			;0914	c0 	. 
	ld a,l			;0915	7d 	} 
	sub e			;0916	93 	. 
	ret			;0917	c9 	.
```

The first thing that happens is the ldir. It'll move 0x91b bytes data from 0x0000 to 0xd000. The player should reside at that address. You can find out about this value from the 7 byte header MSX binary files have. This is all data from before this code until the ret at 0x0917. The moved code will keep executing; the next instruction (ld hl,0d912h) is now at 0xd904. What happens is that 6 bytes starting at 0xd912 will be moved to 0x20h. 0x20h is a BIOS routine on MSX. Since Libkss is not a full computer emulator and because of copyright issues it doesn't have the usual BIOS routines the players expect. This particular player engine needs that BIOS routine, so it's created. Then a "jp 0d006h", that's what starting the music.

What music you ask? Well, the music that should be at 0x4000. To get it there I used a lot of nop entries in this example, they come from empty.bin to get the music at exactly 0x4000 (yes, one nop at 0x4000 but that's in the original MUS file as well so exactly 0x4000 :) ). That's not very elegant. However, if you think about it, it's not as easy as it looks to put it at a clever place. If you put the data right behind the player, you'll need to move that to 4000h using ldir. But, if you include a 16kB file and move it from 0x918 to 0x4000, you overwrite the last part of the data in the process. You can also add the player engine and your own code after the music, move the player+init code, and then move the music, etc., etc. However; you can avoid all the shuffling using memory mapping.

How do I know all these values and things? From NYYRIKKI & BiFi mostly! To find them yourself you'd have to understand all assembly code in the file. But, when you have documentation about a player engine or the original source these values can be found in there. For example the Moonblaster engine is pretty well documented.

Create a KSS file using memory mapping with sjasm
=================================================

Here's the asm file. I won't explain everything, for a programmer this should be readable imho, if you take some time.

However, I will explain the memory mapping. As I said, Z80 can address 64kB. This obviously is not a lot, so the designers of the chip decided to create a memory mapping trick. It can be used to make data from additional memory available at memory areas that the Z80 can address. On MSX you can map those pages to every memory area. The pages normally are 16 kB, which means a page can reside at #0000 until #3fff, from #4000 until #7fff and so on. However the KSS format supports just one area where memory can be mapped to; #8000 until #BFFF. This can be done using the I/O command OUT to port #FE, with in A the page you want to map. Normally pages are 16kB, but 8kB pages are also supported, I haven't looked into that.

The KSS format supports a lot of those pages, like this you can fit a lot of music in one KSS file, up to 4MB.

So how to use this memory mapping? Well in the header you need to specify how many pages you have, it's obvious why. Another important thing is you have to set the Length exactly right. If you for example set a size of 0x100 bytes, Libkss will take 0x101 is the first from the first extra page. It's very clean way of creating KSS files; just put the player in the 'normal' memory area, get it at the right place in memory, map the right music page and play the music. If the player needs to reside somewhere between #8000 and #BFFF you're not in luck, the shuffling will remain!

The ASM file show this, where it's also important to know that the Z80 accumulator, A, contains the current track number when the init routine is being started (at every track). This can be used to select another track in the emulation or another memory page. This example uses the latter. As you can see it's not a lot of code, and the first rule is map the page using the accumulator. The pages are the incbin files, they're exactly 16kB each, so 1 file is 1 page.


  ```
  1           output "merged_fmpac.kss"
  2 
  3 ; KSS-file header:
  4 ;-----------------
  5 
  6         DB "KSCC"                       ; ID string
  7         DW begin_program                ; Start address
  8         DW end_program-begin_program    ; Length
  9         DW init                         ; Init address
 10         DW 0D176H                       ; Interrupt address
 11         DB 0,23,0,1                     ; Other parameters, 23 extra pages (1 for every track) and 1 for FMPAC
 12 
 13         org #D000
 14 
 15 begin_program:
 16 
 17         incbin "FST2.BIN",7		    ; skip MSX header (7 bytes)
 18 
 19 init:
 20         
 21         OUT     (#FE),A                 ; map page to #8000 by track number provided in accumulator
 22 
 23         PUSH    AF
 24         LD      A,1
 25         LD      (0D00CH),A              ; This address means MSX Audio if it's 0, and FMPAC when it's 1, it's 0 by default
 26         POP     AF
 27 
 28         LD      HL,Copy_of_RST20
 29         LD      DE,0020H                ; Player needs RST #20, so we create one.
 30         LD      BC,0006H
 31         LDIR
 32 
 33         CALL    0D077H                  ; Call function in player: move data from mapped page #8000 to #4000
 34         JP      0D006H                  ; Start music
 35 
 36 Copy_of_RST20:
 37         LD      A,H
 38         SUB     D
 39         RET     NZ
 40         LD      A,L
 41         SUB     E
 42         RET
 43 
 44 end_program:
 45         
 46         incbin "IMPACT3/BDD8.MUS",7
 47         incbin "IMPACT3/BREAK.MUS",7
```

You can also look at kss_merge_mus_both_chips_memory_mapped.asm, that's my most advanced thing as of yet. It creates a kss file containing all 23 tracks from Impact music disk 3, where the first 23 tracks are MSX Audio mode and the next 23 for FMPAC.

Playlist Support
================

The most common format for playlists coming with KSS files is M3U, quite a few players support it. However it's also possible to integrate the playlist in the KSS file itself. Afaik this is only support by in_MSX. Maybe that has something to do with the fact that it's completely undocumented. Let's change that. :)

At first you need the extra offset in the extra header (which obviously needs to be enabled, so the format is automatically KSSX) at 0x10 - 0x13. It should contain the exact size of all the KSS data (without header information, which is 0x20 in this case). After that there's room for more data, afaik currently this extra data can be only playlist information. The place in the file where this number is pointing to and the next 3 bytes then must contain the word INFO.

After that byte 8 contains the amount of tracks.

Then starting at position 0x10 there's the info from the first track. Tracks are build up as follows: track id, type, length (ms), fade out (ms) and title.

First track id equals 1 byte.
Then there's a type field from 1 byte, it's always 0, I didn't look into what it actually means.
Then length and fade are both 4 bytes (little endian)
Then the title; this can be a variable amount of characters, it ends at the first moment 0x00 is encountered. 

Then right after that is the second track. The field in byte 8 is used to decide how many tracks will be extracted.

The script display_kss_header.sh will show playlist information if it's available.

That's it for now!

Todo
====

- RAM mode
- Memory mapping details
- How to rip music from games; tips and tricks
