          output "impact_music_disc_3.kss"

; KSS-file header:
;-----------------

        DB "KSCC"			; ID string
        DW begin_program		; Start address
        DW end_program-begin_program	; Length
        DW init				; Init address
        DW 0D176H			; Interrupt address
	DB 1,31,0,9			; Other parameters, 31 extra pages and 9 to enable both MSX Audio and FMPAC emulation

	org #D000

store_samples	EQU	#D003		; Function in the player library that moves samples to MSX Audio ADPCM RAM
move_music	EQU	#D077		; Function that moves music from the memory mapped page to #4000
start_playback	EQU	#D006		; Start playback

begin_program:

	incbin "FST2.bin",7

init:
	CP 	23
	JP	C,msx_audio_mode

	PUSH	AF
	LD	A,1
	LD	(0D00CH),A		; This address means MSX Audio if it's 0, and FMPAC when it's 1, it's 0 by default
	POP	AF
	SUB	23			; Substract tracknumber by 23, so it's track 1 again, but this time on FMPAC mode

	CP	23			; Avoid making Libkss crash when there're no tracks left
	RET	NC

msx_audio_mode:
	LD 	C,A
	ADD 	A,A
	ADD 	A,C
	LD 	C,A
	LD 	B,0
	LD 	HL,table
	ADD 	HL,BC

	LD 	A,(HL)
	OUT 	(#FE),A			; this will map an extra page to #8000-#BFFF
	LD 	A,80H
	LD 	(0D848H),a
	PUSH 	HL
	CALL 	store_samples
	POP 	HL

	INC 	HL
	LD 	A,(HL)
	OUT 	(#FE),A
	LD 	A,80H
	LD 	(0D848H),A
	PUSH 	HL
	CALL 	store_samples
	POP 	HL

	INC 	HL
	LD 	A,(HL)
	OUT 	(#FE),A
	LD 	A,80H
	LD 	(0d848H),A
	CALL 	move_music

	LD	HL,Copy_of_RST20
	LD	DE,0020H		; Player needs RST #20, so we create one.
	LD	BC,0006H
	LDIR

	JP 	start_playback		; Start music

Copy_of_RST20:
	LD	A,H
	SUB	D
	RET	NZ
	LD	A,L
	SUB	E
	RET

table:
	db 1,2,3	; BDD8 DK4
	db 4,5,6	; RADIOGGA DK2
	db 7,8,9	; BREAK DK3
	db 1,2,10	; COPY DK4
	db 1,2,11	; CRIME2 DK4 <-- messed up drums, sounds ok in OpenMSX playing...
	db 1,2,12	; ENDING3 DK4
	db 1,2,13	; ENDING5 DK4
	db 1,2,14	; ENERVTIO DK4
	db 15,16,17	; GRANADA DK1
	db 1,2,18 	; IMPAC165.MUS DK4
	db 1,2,19	; IMPAC181.MUS DK4
	db 1,2,20	; IMPAC183.MUS DK4
	db 1,2,21	; IMPAC187.MUS DK4
	db 1,2,22	; IMPAC195.MUS DK4
	db 1,2,23	; IMPAC196.MUS DK4
	db 15,16,24	; METAL500.MUS DK1
	db 1,2,25	; PSG3.MUS DK4
	db 1,2,26	; RUNOUT.MUS DK4
	db 15,16,27	; SCARFACE.MUS DK1
	db 1,2,28	; STANACS.MUS DK4
	db 1,2,29	; THEME3.MUS DK4
	db 15,16,30	; TURC.MUS DK1
	db 1,2,31	; VROLIKE.MUS DK4


end_program:
	incbin "IMPACT3/DRUMKIT4.SM1",7	; 1
	incbin "IMPACT3/DRUMKIT4.SM2",7	; 2
	incbin "IMPACT3/BDD8.MUS",7	; 3

	incbin "IMPACT3/DRUMKIT2.SM1",7	; 4
	incbin "IMPACT3/DRUMKIT2.SM2",7	; 5
	incbin "IMPACT3/RADIOGGA.MUS",7	; 6

	incbin "IMPACT3/DRUMKIT3.SM1",7	; 7
	incbin "IMPACT3/DRUMKIT3.SM2",7	; 8
	incbin "IMPACT3/BREAK.MUS",7	; 9

	incbin "IMPACT3/COPY.MUS",7	; 10
	incbin "IMPACT3/CRIME2.MUS",7	; 11
	incbin "IMPACT3/ENDING3.MUS",7	; 12
	incbin "IMPACT3/ENDING5.MUS",7	; 13
	incbin "IMPACT3/ENERVTIO.MUS",7	; 14

	incbin "IMPACT3/DRUMKIT1.SM1",7	; 15
	incbin "IMPACT3/DRUMKIT1.SM2",7	; 16
	incbin "IMPACT3/GRANADA.MUS",7	; 17
	
	incbin "IMPACT3/IMPAC165.MUS",7	; 18
	incbin "IMPACT3/IMPAC181.MUS",7	; 19
	incbin "IMPACT3/IMPAC183.MUS",7	; 20
	incbin "IMPACT3/IMPAC187.MUS",7	; 21
	incbin "IMPACT3/IMPAC195.MUS",7	; 22
	incbin "IMPACT3/IMPAC196.MUS",7	; 23
	incbin "IMPACT3/METAL500.MUS",7 ; 24
	incbin "IMPACT3/PSG3.MUS",7	; 25
	incbin "IMPACT3/RUNOUT.MUS",7	; 26
	incbin "IMPACT3/SCARFACE.MUS",7	; 27
        incbin "IMPACT3/STANACS.MUS",7	; 28
        incbin "IMPACT3/THEME3.MUS",7	; 29
        incbin "IMPACT3/TURC.MUS",7	; 30
	incbin "IMPACT3/VROLIKE.MUS",7	; 31
