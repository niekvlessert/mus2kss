          output "merged_fmpac.kss"

; KSS-file header:
;-----------------

        DB "KSCC"			; ID string
        DW begin_program		; Start address
        DW end_program-begin_program	; Length
        DW init				; Init address
        DW 0D176H			; Interrupt address
	DB 0,23,0,1			; Other parameters, 23 extra pages and 1 for FMPAC

	org #d000

begin_program:

	incbin "FST2.BIN",7

init:
	
	OUT 	(#FE),A			; map page to #8000 by track number provided in accumulator

	PUSH	AF
        LD      A,1
        LD      (0D00CH),A              ; This address means MSX Audio if it's 0, and FMPAC when it's 1, it's 0 by default
	POP	AF

	LD	HL,Copy_of_RST20
	LD	DE,0020H		; Player needs RST #20, so we create one.
	LD	BC,0006H
	LDIR

	CALL	0D077H			; Call function in player: move data from mapped page #8000 to #4000
	JP	0D006H			; Start music

Copy_of_RST20:
	LD	A,H
	SUB	D
	RET	NZ
	LD	A,L
	SUB	E
	RET

end_program:
	
	incbin "IMPACT3/BDD8.MUS",7
	incbin "IMPACT3/BREAK.MUS",7
