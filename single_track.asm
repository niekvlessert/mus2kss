; This is just an example, please use the memory mapped version! It's much better.
	output "single_mus.kss"

; KSS-file header:
;-----------------

        DB "KSCC"		; ID string
        DW 0000H		; Start address
	DW 9fffH		; Length
        DW 08f9H		; Init address
	DW 0D176h		; Interrupt address
	DB 0,0,0,1		; Other parameters (See KSS-specification), replace 1 with 8 to emulate MSX audio instead of FMPAC, FST player will adapt automatically

	org #d000

	incbin "player.tmp"
	
	LD	HL,00000H 	; Move player data + own code to correct offset
	LD	DE,0d000H
	LD	BC,begin_music-#d000
	LDIR      
	
	LD	HL,Copy_of_RST20
	LD	DE,0020H   	; Player needs RST #20, so we create one.
	LD	BC,0006H
	LDIR

	JP	0D006H		; Start music

Copy_of_RST20:
	LD	A,H
	SUB	D
	RET	NZ
	LD	A,L
	SUB	E
	RET

begin_music:
	incbin "empty.tmp"	; make sure music starts at 0x4000 (or 0x4010 when looking with xxd, KSS header is 0x10...): dd if=/dev/zero of=empty.tmp bs=14056 count=1
	incbin "bdd8.mus",7

