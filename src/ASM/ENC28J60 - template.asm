.model tiny
.code
EXTRN	newline:NEAR, outbyte:NEAR, outword:NEAR, getc:NEAR, outstr:NEAR
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

LED		equ		0F00h
; To program any register, first the bank must be selected via ECON1

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
		mov		al,01h
		mov		dx,LED
		out		dx,al
init_RX_Buffer:
; init_RX_Buffer requires to init: ERXSDT and ERXND first to determine the size of the Rx/Tx buffer.
		mov		ah,00000000b ; selects ECON1 and sets Bank 0 as active
		mov		al,1fh
		or		al,WCR		 ; adds the opcode
		call	outdata
; programming the start of Rx
		mov		al,08h		; ERXSTL
		or		al,WCR
		mov		ah,00h
		call	outdata
		mov		al,09h		; ERXSTH
		or		al,WCR
		mov		ah,00h
		call	outdata
; programming the end of Rx
		mov		al,0Ah		; ERXNDL
		or		al,WCR
		mov		ah,0ffh
		call	outdata
		mov		al,0Bh		; ERXNDH
		or		al,WCR
		mov		ah,0Fh
		call	outdata
; Now to program ERXRDPT (Ethernet RX ReaD PoinTer)
		mov		al,0Ch		;ERXRDPTL 
		or		al,WCR
		mov		ah,00h
		call	outdata
		mov		al,0Dh
		or		al,WCR
		mov		ah,00h
		call	outdata
; [Completed] INIT_RX_BUFFER
init_MAC:
; to init_MAC, first init MARXEN in MAXCON1
		mov		ah,00000010b ; selects ECON1 and sets Bank 2 as active
		mov		al,1fh
		or		al,WCR
		call	outdata
		mov		al,00h		; MACON1 (Stands for MAc CONtrol 1)
		or		al,WCR
		mov		ah,0Dh
		call	outdata
		mov		al,02h		; MACON3
		or		al,WCR
		mov		ah,0F5h
		call	outdata
		mov		al,03h		; MACON3
		or		al,WCR
		mov		ah,40h
		call	outdata
		mov		al,04h		; MABBIPG
		or		al,WCR
		mov		ah,15h
		call	outdata
		mov		al,06h		; MAIPGL
		or		al,WCR
		mov		ah,12h
		call	outdata
; Now to prgoram the MAC Address with the following: 43:6F:66:66:65:65
		mov		ah,00000011b ; selects ECON1 and sets Bank 3 as active
		mov		al,1fh
		or		al,WCR
		call	outdata
		mov		al,04h		; MAADR1 (MAc ADdRess 1)
		or		al,WCR
		mov		ah,43h
		call	outdata
		mov		al,05h		; MAADR2
		or		al,WCR
		mov		ah,6Fh
		call	outdata
		mov		al,02h		; MAADR3
		or		al,WCR
		mov		ah,66h
		call	outdata
		mov		al,03h		; MAADR4
		or		al,WCR
		mov		ah,66h
		call	outdata
		mov		al,00h		; MAADR5
		or		al,WCR
		mov		ah,65h
		call	outdata
		mov		al,01h		; MAADR6
		or		al,WCR
		mov		ah,65h
		call	outdata
; [COMPLETED] init_MAC
init_PHY:				
; Okay... here it gets complicated. I need to program the PHCON1 register... which is not part of the common registers
; to access the PHY registers, one must pass by the MII register in Bank 2. To program the PHY register, one must also 
; Read from it first then Write to it... i wonder sometimes about these engineers...
		mov		ah,00000010b ; selects ECON1 and sets Bank 2 as active
		mov		ah,1fh
		or		al,WCR
		call	outdata
		mov		al,14h		 ; MIREGADR
		or		al,WCR
		mov		ah,00h
		call	outdata
		mov		al,12h		; MICMD
		or		al,WCR
		mov		ah,01h		; enables read
		call	outdata
		mov		ah,00000011b ; selects ECON1 and sets Bank 3 as active
		mov		al,1fh
		or		al,WCR
		call	outdata
		;call	debug
poll_init_phy:
		mov		al,0Ah
		or		al,RDCR
		call	indata
		and		al,01h
		cmp		al,01h
		je		poll_init_phy
		mov		al,12h			; MICMD
		or		al,WCR
		mov		ah,00h
		call	outdata			; set the read bit back to 0
		mov		al,1fh
		mov		ah,00000010b ; selects ECON1 and sets Bank 2 as active
		or		al,WCR
		call	outdata
		mov		al,19h		 ; MIRDH
		or		al,RDCR
		call	indata
		mov		tmp,al
		mov		al,18h		; MIRDL
		or		al,RDCR
		call	indata
		mov		tmp,ah
; Alright! Read completed!
		or		ah,00000001b
		mov		tmp,ah
		mov		ah,al
		mov		al,18h		; MIRDL
		or		al,WCR
		call	outdata
		mov		ah,tmp
		mov		al,19h		; MIRDH
		or		al,WCR
		call	outdata
		mov		ah,00000011b ; ECON1, Bank3
		mov		al,1fh
		or		al,WCR
		call	outdata
poll_init_phy_2:
		mov		al,0Ah		;MISTAT
		or		al,RDCR
		call	indata
		and		al,01h
		cmp		al,01h
		je		poll_init_phy_2
;[COMPLETED]  INIT_PHY
		mov		ah,00000100b 		; selects ECON1 and sets Bank 0 as active and Rx as Active
		mov		al,1fh
		or		al,WCR		 ; adds the opcode
		call	outdata
		mov		al,05h
		mov		dx,LED
		out		dx,al
here:	;call	txtst
		;jmp here
		mov		al,1fh
		or		al,WCR
		mov		ah,03h
		call	outdata
		
		mov		al,04h
		or		al,RDCR
		call	indata
		call	outbyte
		call	newline
		mov		al,05h
		or		al,RDCR
		call	indata
		call	outbyte
		call	newline
		mov		al,02h
		or		al,RDCR
		call	indata
		call	outbyte
		call	newline
		mov		al,03h
		or		al,RDCR
		call	indata
		call	outbyte
		call	newline
		mov		al,00h
		or		al,RDCR
		call	indata
		call	outbyte
		call	newline
		mov		al,01h
		or		al,RDCR
		call	indata
		call	outbyte
		call	newline
		call	newline
lawl:	jmp		here



tmp		db 0	
main    endp

txtst	proc
	lea		di,udp_hdr
	mov		al,1fh
	or		al,WCR
	mov		ah,00000000b
	call	outdata
	mov		al,04h
	or		al,WCR
	mov		ah,00h
	call	outdata
	mov		al,05h
	or		al,WCR
	mov		ah,01h
	call	outdata
	mov		cl,0
hdr:
	mov		ah,[di]
	mov		al,WBR
	call	outdata
	inc		cl
	inc		di
	cmp		cl,7
	jbe		hdr
	mov		ch,cl
	mov		cl,0
	lea		di,ip_hdr

	mov		al,09h
	mov		dx,LED
	out		dx,al
;ip:		
;	mov		ah,[di]
;	mov		al,WBR
;	call	outdata
;	inc		cl
;	inc		di
;	cmp		cl,20
;	jbe		ip
	mov		al,ch
	add		al,cl
	mov		cl,al
data:
	mov		al,WBR
	mov		ah,0AAh
	call	outdata
	inc		cl
shi:
	mov		ah,cl
	mov		al,06h
	or		al,WCR
	call	outdata
	mov		al,07h
	or		al,WCR
	mov		ah,01h
	call	outdata
start_tx:
	mov		al,1fh
	or		al,RDCR
	call	indata
	or		al,00001000b
	call	outbyte
	mov		ah,al
	mov		al,1fh
	or		al,WCR
	call	outdata
poll:
	mov		al,0Dh
	mov		dx,LED
	out		dx,al
	
	mov		al,1fh
	or		al,RDCR
	call	indata
	and		al,00001000b
;	call	outbyte
	cmp		al,00001000b
	je		poll
	ret
txtst	endp

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

;chksum proc ;[UNTESTED]
; this function is to calculate the checksum for the IP and TCP header fields

;chksum endp

;debug proc
;	push	ax
;	push	di
;	lea		di,dbg
;	call	outstr
;	call	newline
;	pop		di
;	pop		ax
;	ret
;dbg		db "[DEBUG]",04
;debug endp

outdata proc	;[WORKING] also used for writing to registers
; Al.b7 Must have the first bit to send and ah must have the data to send
	push	bx			; need this for bogus
	mov		bx,0
	mov		cl,0		; the bit counter
	mov		dx,PORTC
	push	ax
	mov		al,00h
	out		dx,al
	pop		ax
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
	mov		dx,PORTC
	mov		al,0f0h
	out		dx,al
	push	ax
	mov		al,RESET
	mov		dx,PPICTL
	out		dx,al
	pop		ax
	pop		bx
	ret
outdata endp

indata proc 	;[WORKING]
; Al.b7 Must have the first bit to send and ah must have the data to send
	push	bx			; need this for bogus
	mov		bx,0
	mov		cl,0		; the bit counter
	lea		di,vals
	mov		dx,PORTC
	push	ax
	mov		al,00h
	out		dx,al
	pop		ax
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
	je		bogus2
	inc		cl
	jmp		bogus		; Not quite, but good for now
bogus2:
	push	ax
	mov		dx,PPICTL
	mov		al,RESET
	out		dx,al
	pop		ax
	mov		dx,PORTA
	in		al,dx
	mov		[di],al
	inc		bx
	cmp		cl,45
	je		inbit
	inc		bl
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
	jmp		bogus2
shi:
	mov		al,RESET
	mov		dx,PPICTL
	out		dx,al
	mov		dx,PORTC
	mov		al,0f0h
	out		dx,al
	lea		di,vals
	mov		cl,1
	
	mov		al,[di]
	and		al,80h
	mov		dl,al
	inc		di
	mov		al,[di]
	and		al,80h
	ror		al,cl
	inc		cl
	add		dl,al
	inc		di
	mov		al,[di]
	and		al,80h
	ror		al,cl
	inc		cl
	add		dl,al
	inc		di
	mov		al,[di]
	and		al,80h
	ror		al,cl
	inc		cl
	add		dl,al
	inc		di
	mov		al,[di]
	and		al,80h
	ror		al,cl
	inc		cl
	add		dl,al
	inc		di
	mov		al,[di]
	and		al,80h
	ror		al,cl
	inc		cl
	add		dl,al
	inc		di
	mov		al,[di]
	and		al,80h
	ror		al,cl
	inc		cl
	add		dl,al
	inc		di
	mov		al,[di]
	and		al,80h
	ror		al,cl
	add		dl,al
	mov		al,dl
	pop		bx
	ret
vals db 0,0,0,0,0,0,0,0
indata endp
		end

