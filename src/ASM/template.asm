.model tiny
.code
EXTRN	newline:NEAR, outbyte:NEAR, outword:NEAR, getc:NEAR, putc:NEAR, outstr:NEAR
; Eth0 preprocessor
ETH0    equ     0A00h   ;PPI2 + Eth_Controller
PORTA   equ     ETH0+0
PORTB   equ     ETH0+1
PORTC   equ     ETH0+2
PPICTL  equ     ETH0+3
SET		equ		00000001b
RESET	equ		00000000b
BANK0	equ		00010000b	; eth0 Memory bank 0
BANK1	equ		00010001b
BANK2	equ		00010010b
BANK3	equ		00010011b	; to 3
RDCR	equ		00000000b	; Read control register (Req, Arg.)
RDBM	equ		00111010b	; Read buffer register
WCR		equ		01000000b	; write control register (Req, Arg + Data Byte)
WBR		equ		01111010b	; write buffer register (Req, Data Byte)
BFS		equ		10000000b	; Bit field set (Req, Arg + Data Byte)
BFC		equ		10100000b	; Bit field clear (Req, Arg + Data Byte)
SRC		equ		11111111b	; Soft Reset

; To program any register, first the bank must be selected via ECON1

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
init_RX_Buffer:
; init_RX_Buffer requires to init: ERXSDT and ERXND first to determine the size of the Rx/Tx buffer.
		mov		al,00010000b ; selects ECON1 and sets Bank 0 as active
		or		al,WCR		 ; adds the opcode
		call	outbyte
; programming the start of Rx
		mov		al,08h		; ERXSTL
		or		al,WCR
		mov		ah,00h
		call	outword
		mov		al,09h		; ERXSTH
		or		al,WCR
		mov		ah,00h
		call	outword
; programming the end of Rx
		mov		al,0Ah		; ERXNDL
		or		al,WCR
		mov		ah,0ffh
		call	outword
		mov		al,0Bh		; ERXNDH
		or		al,WCR
		mov		ah,0Fh
		call	outword
; Now to program ERXRDPT
		mov		al,0Ch		;ERXRDPTL 
		or		al,WCR
		mov		ah,00h
		call	outword
		mov		al,0Dh
		or		al,WCR
		mov		ah,00h
		call	outword
; [Completed] INIT_RX_BUFFER
init_MAC:
; to init_MAC, first init MARXEN in MAXCON1
		mov		al,00010010b ; selects ECON1 and sets Bank 2 as active
		or		al,WCR
		call	outbyte
		mov		al,00h		; MACON1 (Stands for MAc CONtrol 1)
		or		al,WCR
		mov		ah,0Dh
		call	outword
		mov		al,02h		; MACON3
		or		al,WCR
		mov		ah,0F5h
		call	outword
		mov		al,03h		; MACON3
		or		al,WCR
		mov		ah,40h
		call	outword
		mov		al,04h		; MABBIPG
		or		al,WCR
		mov		ah,15h
		call	outword
		mov		al,06h		; MAIPGL
		or		al,WCR
		mov		ah,12h
		call	outword
; Now to prgoram the MAC Address with the following: 43:6F:66:66:65:65
		mov		al,00010011b ; selects ECON1 and sets Bank 3 as active
		or		al,WCR
		call	outbyte
		mov		al,04h		; MAADR1 (MAc ADdRess 1)
		or		al,WCR
		mov		ah,43h
		call	outword
		mov		al,05h		; MAADR2
		or		al,WCR
		mov		ah,6Fh
		call	outword
		mov		al,02h		; MAADR3
		or		al,WCR
		mov		ah,66h
		call	outword
		mov		al,03h		; MAADR4
		or		al,WCR
		mov		ah,66h
		call	outword
		mov		al,00h		; MAADR5
		or		al,WCR
		mov		ah,65h
		call	outword
		mov		al,01h		; MAADR6
		or		al,WCR
		mov		ah,65h
		call	outword
; [COMPLETED] init_MAC
init_PHY:				
; Okay... here it gets complicated. I need to program the PHCON1 register... which is not part of the common registers
; to access the PHY registers, one must pass by the MII register in Bank 2. To program the PHY register, one must also 
; Read from it first then Write to it... i wonder sometimes about these engineers...
		mov		al,00010010b ; selects ECON1 and sets Bank 2 as active
		or		al,WCR
		call	outbyte
		mov		al,14h		 ; MIREGADR
		or		al,WCR
		mov		ah,00h
		call	outword
		mov		al,12h		; MICMD
		or		al,WCR
		mov		ah,01h		; enables read
		call	outword
		mov		al,00010011b ; selects ECON1 and sets Bank 3 as active
		or		al,WCR
		call	outbyte
poll_init_phy:
		mov		al,0Ah
		or		al,RDCR
		call	inwordM
		and		al,01h
		cmp		al,01h
		je		poll_init_phy
		mov		al,12h			; MICMD
		or		al,WCR
		mov		ah,00h
		call	outbyte			; set the read bit back to 0
		mov		al,00010010b ; selects ECON1 and sets Bank 2 as active
		or		al,WCR
		call	outbyte
		mov		al,19h		 ; MIRDH
		or		al,RDCR
		call	inbyteM
		mov		tmp,al
		mov		al,18h		; MIRDL
		or		al,RDCR
		call	inbyteM
		mov		tmp,ah
; Alright! Read completed!
		or		ah,00000001b
		mov		tmp,ah
		mov		ah,al
		mov		al,18h		; MIRDL
		or		al,WCR
		call	outbyte
		mov		ah,tmp
		mov		al,19h		; MIRDH
		or		al,WCR
		call	outbyte
		mov		al,00010011b ; ECON1, Bank3
		or		al,WCR
		call	outbyte
poll_init_phy_2:
		mov		al,0Ah		;MISTAT
		or		al,RDCR
		call	inwordM
		and		al,01h
		cmp		al,01h
		je		poll_init_phy_2
;[COMPLETED]  INIT_PHY
mov		al,00010100b 		; selects ECON1 and sets Bank 0 as active and Rx as Active
		or		al,WCR		 ; adds the opcode
		call	outbyte
		
here:	jmp here

tmp		db 0	
main    endp

udp_hdr db 26h, 17h, 26h, 17h, 1Ch, 00h, 00h
;source port(16)	: 0x2617
;dest. port (16)	: 0x2617
;length (16)		: 0x001C
;checksum (16)		: 0x0000 (Default)

tcp_hdr db 26h, 17h, 26h, 17h, 00h, 00h, 00h, 00h
;source port (16)   : 0x2617
;dest. port(16)		: 0x2617
;sequence # (32)	: 0x0000 0x0000 (?)
;Ack # (32)			: 
;Data Offset (4)	:
;Reserve	(12)	:
;Window		(16)	:
;Checksum	(16)	:
;Urgent ptr (16)	:
;Options	(24)	:
;Padding	(8)		:

ip_hdr	db 45h, 00h, 00h, 14h, 01h, 40h, 00h, 06h, 00h, 00h, 0C0h, 0A8h, 00h, 0E1h, 0C0h, 0A8h, 00h, 0E1h, 0B0h, 00h ;last one is my data codes
;version (4)		: 0100 (4h)
;IHL (4)			: 0101 (?) (5h)
;Type of Service (8): 0000 0000 (00h)
;Total Length	(16): 0000 0000 (00h), 0001 0100 (14h) (20d) don't need more, i'm sending single byte codes... bad overhead
;ID	(8)				: 0000 0001 (01h) (?)
;Flags (3)			: 010 (2h) ; Don't fragment and Last fragment }
;Fragment offset(13): 0 0000 0000 0000 (00h)					  } 0100 0000 0000 0000
;TTL	(8)			: 1000 0000 (80h)
;Protocol (8)		: 0000 0110 (06h) (TCP=0x06 UDP=0x11)
;Header Checksum(16): 0000 0000, 0000 0000 (variable)
;Source address (32): 1100 0000, 1010 1000, 0000 0000, 1110 0001 (192.168.0.225)
;Destination AD(32) : 1100 0000, 1010 1000, 0000 0000, 1011 0000 (192.168.0.176)
;Options (24)		: No Need
;Padding (8)		: Most likely need some padding


inbyte proc	;[UNTESTED]
; AX.b3 Must have the first bit to send
	pop		bx			; need this for bogus
	mov		bx,0
	mov		cl,0		; the bit counter
	lea		di,temp
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
	mov		[di],al
	inc		di
	cmp		cl,15
	je		shi
	inc		cl
	jmp		inbogus
shi:
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
inbyte endp

outbyte proc	;[WORKS] 
; AX.b3 Must have the first bit to send
	pop		bx			; need this for bogus
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
	cmp		cl,7
	je		shi
	inc		cl
	jmp		bogus		; Not quite, but good for now
shi:
	pop		bx
	ret
outbyte endp

outword proc	;[UNTESTED]
; AX.b3 Must have the first bit to send and ah must have the data to send
	pop		bx			; need this for bogus
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
	pop		bx
	ret
outword endp
		end
		