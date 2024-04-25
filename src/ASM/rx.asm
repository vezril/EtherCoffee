.model tiny
.code
; external commands (m88io.obj) preprocessor
EXTRN	newline:NEAR, outbyte:NEAR, outword:NEAR, getc:NEAR, outc:NEAR, outstr:NEAR
;eth0 preprocessor
ETH0    	equ     0A00h 
RXTX0L		equ		ETH0+00h
RXTX0H		equ		ETH0+01h
RXTX1L		equ		ETH0+02h
RXTX1H		equ		ETH0+03h
TXCMDL		equ		ETH0+04h
TXCMDH		equ		ETH0+05h
TXLENGTHL	equ		ETH0+06h
TXLENGTHH	equ		ETH0+07H
ISQL		equ		ETH0+08h
ISQH		equ		ETH0+09H
PPPL		equ		ETH0+0AH
PPPH		equ		ETH0+0BH
PPD0L		equ		ETH0+0CH
PPD0H		equ		ETH0+0DH
PPD1L		equ		ETH0+0EH
PPD1h		equ		ETH0+0FH
; I/O preprocessor
LED			equ		0F00h
PPI			equ		0200h
PORTA   	equ     PPI+0
PORTB   	equ     PPI+1
PORTC   	equ     PPI+2
PPICTL  	equ     PPI+3

        org     0800h
main    proc
init:
		cli
		mov		ax,0
        mov     al,10010000b    ;configuration word for the 8255
                                ;both group A and B = mode 0
                                ;port A = input
                                ;port B = output
                                ;port C = output
        mov     dx,PPICTL
        out     dx,al         ;send the configuration word 
		mov		dx,0
		mov		cx,0
reset_wait:				; Just to give eth0 to
		inc		cx 		;init internally
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		cmp		cx,07fffh
		jbe		reset_wait
		mov		dx,LED
		mov		al,01h
		out		dx,al
eth0_init:
;MAC_INIT	
		mov		dx,PPPL
		mov		al,12h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,0D3h
		out		dx,al
		mov		dx,PPD0H
		mov		al,00h
		out		dx,al		
		mov		dx,PPPL
		mov		al,58h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,000h
		out		dx,al
		mov		dx,PPD0H
		mov		al,6Fh
		out		dx,al		
		mov		dx,PPPL
		mov		al,5Ah
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,066h
		out		dx,al
		mov		dx,PPD0H
		mov		al,66h
		out		dx,al		
		mov		dx,PPPL
		mov		al,5Ch
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,065h
		out		dx,al
		mov		dx,PPD0H
		mov		al,65h
		out		dx,al
;TestCTL
		mov		dx,PPPL
		mov		al,18h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,00h ;10011001b
		out		dx,al
		mov		dx,PPD0H
		mov		al,00h ;01000000b
		out		dx,al
; BufferCFG
		; mov		dx,PPPL
		; mov		al,0Ah
		; out		dx,al
		; mov		dx,PPPH
		; mov		al,01h
		; out		dx,al
		; mov		dx,PPD0L
		; mov		al,00001011b
		; out		dx,al
		; mov		dx,PPD0H
		; mov		al,00000000b
		; out		dx,al
; LineCTL		
		mov		dx,PPPL
		mov		al,12h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,0c0h ;11010011b
		out		dx,al
		mov		dx,PPD0H
		mov		al,00000000b
		out		dx,al
; SelfCTL
		; mov		dx,PPPL
		; mov		al,14h
		; out		dx,al
		; mov		dx,PPPH
		; mov		al,01h
		; out		dx,al
		; mov		dx,PPD0L
		; mov		al,00010101b
		; out		dx,al
		; mov		dx,PPD0H
		; mov		al,00000000b
		; out		dx,al
; BusCTL
		; mov		dx,PPPL
		; mov		al,16h
		; out		dx,al
		; mov		dx,PPPH
		; mov		al,01h
		; out		dx,al
		; mov		dx,PPD0L
		; mov		al,00010111b
		; out		dx,al
		; mov		dx,PPD0H
		; mov		al,00000000b
		; out		dx,al		
; RxCFG
		; mov		dx,PPPL
		; mov		al,02h
		; out		dx,al
		; mov		dx,PPPH
		; mov		al,01h
		; out		dx,al
		; mov		dx,PPD0L
		; mov		al,00000011b
		; out		dx,al
		; mov		dx,PPD0H
		; mov		al,00001000b
		; out		dx,al
; RxCTL
		mov		dx,PPPL
		mov		al,04h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,01000000b ;01000101b ;80h ;11000101b
		out		dx,al
		mov		dx,PPD0H
		mov		al,00111001b;7fh ;01h ;01111101b
		out		dx,al	
; TxCFG
		mov		dx,PPPL
		mov		al,06h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,00000111b
		out		dx,al
		mov		dx,PPD0H
		mov		al,00000000b
		out		dx,al
		call	display_mac
tst:
		mov		dx,RXTX0L
		in		al,dx
		call	outbyte
		mov		dx,RXTX0H
		in		al,dx
		call	outbyte
		jmp		tst
poll:
		mov		dx,PPPL
		mov		al,24h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		in		al,dx
		mov		tmp,al
		mov		dx,PPD0H
		in		al,dx
		mov		ah,al
		mov		al,tmp
		
		and		ah,01h
		cmp		ah,01h
		jne		poll
		call	recv		
here:	jmp		poll ;here

main    endp

recv	proc
		; mov		dx,PPD0H
		; in		al,dx
		; mov		tmp,al
		; mov		dx,PPD0L
		; in		al,dx
		; mov		ah,tmp		;RxSTATUS
		; call	outword
		; call	newline
		mov		dx,PPPL
		mov		al,12h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,00010011b
		out		dx,al
		mov		dx,PPD0H
		mov		al,00h
		out		dx,al
		
		mov		dx,RXTX0H
		in		al,dx
		xchg	ah,al
		mov		dx,RXTX0L
		in		al,dx	;RxStatus	
		call	outword
		call	newline
		mov		dx,RXTX0H
		in		al,dx
		xchg	ah,al
		mov		dx,RXTX0L
		in		al,dx		;RxLENGTH
		
		call	outword
		call	newline

		mov		dx,RXTX0L
		in		al,dx
		mov		tmp,al
		mov		dx,RXTX0H
		in		al,dx
		mov		ah,al
		mov		al,tmp
		call	outword
		mov		dx,RXTX0L
		in		al,dx
		mov		tmp,al
		mov		dx,RXTX0H
		in		al,dx
		mov		ah,al
		mov		al,tmp
		call	outword
		mov		dx,RXTX0L
		in		al,dx
		mov		tmp,al
		mov		dx,RXTX0H
		in		al,dx
		mov		ah,al
		mov		al,tmp
		call	outword
		call	newline
		call	newline
		
		mov		dx,PPPL
		mov		al,12h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,11010011b
		out		dx,al
		mov		dx,PPD0H
		mov		al,00h
		out		dx,al
		
		
		ret
recv	endp

; inc_ppp	proc
		; mov		dx,PPPL
		; in		al,dx		;al = LSB
		; mov		bl,al		;al = NULL, bl = LSB
		; mov		dx,PPPH
		; in		al,dx		;al = MSB, bl = LSB
		; mov		ah,al		;ah = MSB, al = NULL, bl = LSB
		; mov		al,bl		;ah = MSB, al = LSB, bl = NULL
		; inc		ax			;PPP+1
		; inc		ax			;PPP+2
		; mov		bl,ah		;ah = NULL, al = LSB, bl = MSB
		; mov		dx,PPPL		
		; out		dx,al		;LSB is Set; ah = NULL, al = NULL, bl = MSB
		; mov		al,bl		;al = MSB, bl = NULL
		; mov		dx,PPPH		
		; out		dx,al		;MSB Set
		; ret
; inc_ppp	endp
;
; display_ppp proc
		; mov		dx,PPPL
		; in		al,dx
		; mov		tmp,al
		; mov		dx,PPPH
		; in		al,dx
		; mov		ah,al
		; mov		al,tmp
		; and		ax,1000111111111111b	;Masks out the Read-Only Bits (ROB = 011)
		; call	outword
		; call	newline
		; ret
; display_ppp endp
;		
; display_ppd	proc
		; mov		dx,PPD0L
		; in		al,dx
		; mov		tmp,al
		; mov		dx,PPD0H
		; in		al,dx
		; mov		ah,al
		; mov		al,tmp
		; call	outword
		; call	newline
		; ret
; display_ppd	endp

display_mac	proc
		lea		di, mac	
		mov		dx,PPPL
		mov		al,58h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		in		al,dx
		mov		[di],al
		inc		di
		mov		dx,PPD0H
		in		al,dx
		mov		[di],al
		inc		di		
		mov		dx,PPPL
		mov		al,5Ah
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		in		al,dx
		mov		[di],al
		inc		di
		mov		dx,PPD0H
		in		al,dx
		mov		[di],al
		inc		di		
		mov		dx,PPPL
		mov		al,5Ch
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		in		al,dx
		mov		[di],al
		inc		di
		mov		dx,PPD0H
		in		al,dx
		mov		[di],al
		inc		di		
		lea		di, mesg_mac
		call	outstr
		lea		di,mac
		mov		al,[di]
		call	outbyte
		mov		al,3Ah
		call	outc
		inc		di
		mov		al,[di]
		call	outbyte
		mov		al,3Ah
		call	outc
		inc		di
		mov		al,[di]
		call	outbyte
		mov		al,3Ah
		call	outc
		inc		di
		mov		al,[di]
		call	outbyte
		mov		al,3Ah
		call	outc
		inc		di
		mov		al,[di]
		call	outbyte
		mov		al,3Ah
		call	outc
		inc		di
		mov		al,[di]
		call	outbyte
		ret
display_mac	endp


mac			db 00,00,00,00,00,00
mesg_mac	db "The MAC Address of this System is: ",04
msg			db	"Frame captured.",04
tmp 		db  00h
		end

