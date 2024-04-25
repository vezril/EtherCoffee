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
		mov		al,01h
		mov		dx,LED
		out		dx,al
		mov		dx,0
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
		mov		al,043h
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
; LineCTL		
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
		mov		al,02h
		out		dx,al
		call	display_mac
tx_tst:
;setting up the TxCMD
		mov		dx,TXCMDL
		mov		al,0C0h
		out		dx,al
		mov		dx,TXCMDH
		mov		al,00h
		out		dx,al
;setting up the TxLength
		mov		dx,TXLENGTHL
		mov		al,78h ;2Bh		;[LENGTH!!!!!]
		out		dx,al
		mov		dx,TXLENGTHH
		mov		al,00h
		out		dx,al
;Packet Page Pointer Set-up
PPP:
		mov		dx,PPPL
		mov		al,38h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
;Reading the Packet Page Pointer Data
		
		mov		dx,PPD0H
		in		al,dx		
		and		al,01h
		cmp		al,01h
		jne		PPP
		lea		di,udp_hdr
		mov		cl,0
;start moving data
tx_data:
		;destination MAC
		mov		dx,RXTX0L
		mov		al,00h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,26h
		out		dx,al
		mov		dx,RXTX0L
		mov		al,2dh
		out		dx,al
		mov		dx,RXTX0H
		mov		al,7ch
		out		dx,al
		mov		dx,RXTX0L
		mov		al,073h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,0b5h
		out		dx,al
		;Source MAC
		mov		dx,RXTX0L
		mov		al,43h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,6fh
		out		dx,al
		mov		dx,RXTX0L
		mov		al,66h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,66h
		out		dx,al
		mov		dx,RXTX0L
		mov		al,65h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,65h
		out		dx,al
		;type
		mov		dx,RXTX0L
		mov		al,08h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,00h
		out		dx,al
		;ip hdr
		;version, header length
		mov		dx,RXTX0L
		mov		al,45h
		out		dx,al
		;services
		mov		dx,RXTX0H
		mov		al,00h
		out		dx,al
		mov		dx,RXTX0L
		mov		al,00h
		out		dx,al
		;total length
		mov		dx,RXTX0H
		mov		al,14h
		out		dx,al
		;ID
		mov		dx,RXTX0L
		mov		al,01h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,40h
		out		dx,al
		;Flags
		mov		dx,RXTX0L
		mov		al,00h
		out		dx,al
		;Fragment Offset
		mov		dx,RXTX0H
		mov		al,00h
		out		dx,al
		;TTL
		mov		dx,RXTX0L
		mov		al,05h
		out		dx,al
		;protocl
		mov		dx,RXTX0H
		mov		al,11h
		out		dx,al
		;Checksum
		mov		dx,RXTX0L
		mov		al,031h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,0b8h
		out		dx,al
		;Source Address
		mov		dx,RXTX0L
		mov		al,0c0h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,0a8h
		out		dx,al
		mov		dx,RXTX0L
		mov		al,00h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,0e1h
		out		dx,al
		;Destination Address
		mov		dx,RXTX0L
		mov		al,0c0h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,0a8h
		out		dx,al
		mov		dx,RXTX0L
		mov		al,00h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,0b0h
		out		dx,al
		;udp hdr
		;souce port
		mov		dx,RXTX0L
		mov		al,26h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,17h
		out		dx,al
		;destination port
		mov		dx,RXTX0L
		mov		al,26h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,17h
		out		dx,al
		;length
		mov		dx,RXTX0L
		mov		al,00h
		out		dx,al
		mov		dx,RXTX0H
		mov		al,52h
		out		dx,al
		;chksum
		mov		dx,RXTX0L
		mov		al,chk_sum
		out		dx,al
		mov		dx,RXTX0H
		mov		al,chk_sum+1
		out		dx,al
		;data
		mov		dx,RXTX0L
		mov		al,data
		out		dx,al
		mov		dx,RXTX0H
		mov		al,data+1
		out		dx,al
		mov		cl,0
pad:
	;	;padding
		mov		dx,RXTX0L
		mov		al,0aah
		out		dx,al
		mov		dx,RXTX0H
		mov		al,0bbh
		out		dx,al
		inc		cl
		cmp		cl,23h
		jbe		pad
		mov		dx,RXTX0L
		mov		al,0aeh
		out		dx,al
		mov		dx,RXTX0H
		mov		al,058h
		out		dx,al
		mov		dx,RXTX0L
		mov		al,0cdh
		out		dx,al
		mov		dx,RXTX0H
		mov		al,073h
		out		dx,al
		
shi:
		lea		di,end_msg
		call	newline
		call	outstr
		call	getc
		mov		data,al
		jmp		tx_tst

chk_sum db 00, 00
main    endp

udp_hdr db 00h, 1dh, 72h, 56h, 0d3h, 2dh, 43h, 6fh, 66h, 66h, 65h, 65h, 08h, 00h, 26h, 17h, 26h, 17h, 1Ch, 00h, 00h, 45h, 00h, 00h, 14h, 01h, 40h, 00h, 06h, 00h, 00h, 0C0h, 0A8h, 00h, 0E1h, 0C0h, 0A8h, 00h, 0E1h, 0B0h, 00h
;source port(16)	: 0x2617
;dest. port (16)	: 0x2617
;length (16)		: 0x001C
;checksum (16)		: 0x0000 (Default)
;00h, 1dh, 72h, 56h, 0d3h, 2dh, 43h, 6fh, 66h, 66h, 65h, 65h, 08h, 00h, 
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

data		db 00,00
mac			db 00,00,00,00,00,00
mesg_mac	db "The MAC Address of this System is: ",04
end_msg		db "Press any key to send another packet... ",04
display_mac	endp
		end

