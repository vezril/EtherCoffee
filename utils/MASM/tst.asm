.model tiny
.code

EXTRN newline:NEAR, outbyte:NEAR, outword:NEAR, getc:NEAR

LED		equ		0f00h
PPI     equ     0A00h   ;PPI2 + Eth0
PORTA   equ     PPI+0
PORTB   equ     PPI+1
PORTC   equ     PPI+2
PPICTL  equ     PPI+3
SET		equ		00000001b
RESET	equ		00000000b
WCR		equ		01000000b
RDCR	equ		00000000b
        org     0800h
main    proc
init:
        mov     al,10010000b    ;configuration word for the 8255
                                ;both group A and B = mode 0
                                ;port A = input
                                ;port B = output
                                ;port C = output
        mov     dx,PPICTL
        out     dx,al         ;send the configuration word 
		mov		dx,PORTC
		mov		al,0ffh		;CS for ETH0
		out		dx,al

tst:
		mov		dx,LED
		mov		al,5h
		out		dx,al
		mov		al,1fh
		or		al,WCR
		mov		ah,00010111b
		call	outdata
		mov		al,15h
		or		al,WCR
		mov		ah,00000101b
		call	outdata
here:
		mov		al,1Eh
		mov		save,al
		call	outbyte
		or		al,RDCR
		call	inreg
		mov		save,al
		call	newline
		call	outbyte
		

save	db	0ffh		
main    endp

inreg proc
; Al.b7 Must have the first bit to send
	push	bx			; need this for bogus
	mov		bx,0
	mov		cl,0		; the bit counter
	lea		di,temp
	mov		dx,PORTC
	mov		al,00h
	out		dx,al
outbogus:
	push	ax			; this is all bogus
	mov		dx,PPICTL	; it is used to keep
	mov		al,RESET	; a 50% duty cycle
	out 	dx,al		; on the SET/RESET
	pop		ax
	mov		dx,PORTB
	out		dx,al
	rol		bx,1
	cmp		bl,45
	je		outbit
	inc		bl
	jmp		outbit
outbit:
	push	ax
	mov		dx,PPICTL
	mov		al,SET
	out		dx,al		; bit is set
	pop		ax
	mov		dx,PORTB
	out		dx,al		; Out MSB (present)
	rol		ax,1		; next bit to out
	cmp		cl,7
	je		inbogus
	inc		cl
	jmp		outbogus		; Not quite, but good for now
inbogus:
	push	ax
	mov		dx,PPICTL
	mov		al,RESET
	out		dx,al
	pop		ax
	mov		dx,PORTA
	in		al,dx
	and		al,10000000b
	mov		[di],al
	inc		dx
	cmp		cl,45
	je		inbit
	inc		dx
	jmp		inbit
inbit:
	push	ax
	mov		dx,PPICTL
	mov		al,SET
	out		dx,al
	pop		ax
	mov		dx,PORTA
	in		al,dx
	and		al,10000000b
	mov		[di],al
	inc		di
	cmp		cl,15
	je		shi
	inc		cl
	jmp		inbogus
shi:
	mov		dx,PORTC
	mov		al,0FFh
	out		dx,al
	mov		cl,1
	mov		dl,temp
	mov		al,temp+1
	ror		al,cl
	add		dl,al
	inc		cl
	mov		al,temp+2
	ror		al,cl
	add		dl,al
	inc		cl
	mov		al,temp+3
	ror		al,cl
	add		dl,al
	inc		cl
	mov		al,temp+4
	ror		al,cl
	add		dl,al
	inc		cl
	mov		al,temp+5
	ror		al,cl
	add		dl,al
	inc		cl
	mov		al,temp+6
	ror		al,cl
	add		dl,al
	inc		cl
	mov		al,temp+7
	ror		al,cl
	add		dl,al
	mov		al,dl
	and		ax,0fh
	pop		bx
	ret
	
temp db 0,0,0,0,0,0,0,0
inreg endp
outdata proc
; AX.b3 Must have the first bit to send and ah must have the data to send
	push	bx			; need this for bogus
	mov		bx,0
	mov		cl,0		; the bit counter
bogus:
	push	ax			; this is all bogus
	mov		dx,PPICTL	; it is used to keep
	mov		al,RESET	; a 50% duty cycle
	out 	dx,al		; on the SET/RESET
	pop		ax
	mov		dx,PORTB
	out		dx,al
	rol		bx,1
	cmp		bl,45
	je		outbit
	inc		bl
	jmp		outbit
outbit:
	push	ax
	mov		dx,PPICTL
	mov		al,SET
	out		dx,al		; bit is set
	pop		ax
	mov		dx,PORTB
	out		dx,al		; Out MSB (present)
	rol		ax,1		; next bit to out
	cmp		cl,15
	je		shi
	inc		cl
	jmp		bogus		; Not quite, but good for now
shi:
	push	ax
	mov		al,RESET
	mov		dx,PPICTL
	out		dx,al
	pop		ax
	pop		bx
	ret
outdata endp
      end
