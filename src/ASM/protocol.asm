; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU Public Liscence, or by
; the Free Software Foundation, either version 3 of the License, or
; any later version.
; This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY of FITNESS FOR A PARTICULAR PURPOSE. See the GNU
; General Public Liscence for more details.
;
; You should have received a copy of the GNU General Public Liscence
; along with this program. If not, see <http://www.gnu.org/licences/>.

; EtherCoffee Firmware v1.0 Copyright (C) 2010 Calvin O. Ference

.model tiny
.code

ROM     equ     0E000h
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
LED			equ		0E00h
PPI			equ		0200h
PORTA   	equ     PPI+0
PORTB   	equ     PPI+1
PORTC   	equ     PPI+2
PPICTL  	equ     PPI+3
; PIC preprocessor
PIC			equ		400h
ICW1  	 	equ		PIC
ICW2  		equ		PIC+1
ICW4    	equ		PIC+1
OCW1    	equ		PIC+1
ICW1B   	equ		00010011b   ;edge trig
ICW2B   	equ		01000000b   ;vec. no. 40h = 100h
ICW4B   	equ		00000011b
OCW1B   	equ		11111110b
FREQ		equ		2400
; ADC preproc
ADCON		equ		0800h

; #defines
DSTATUS		equ		0A0h
DIDLE		equ		0A1h
DBREW		equ		0A2h

DWATER		equ		0B0h

DPROTO		equ		0C0h
DACK		equ		0C1h

        org     	1000h
		; eth0 Data
mac			db 00,00,00,00,00,00
data		db 00,00
chk_sum 	db 00, 00

;RTC
tick		dw	0
time		db  0

;flags
flag		db	0
cups_flag	db	0
brewing_flag		db	0
; Temporary Storage Area
tmp 		db  00h
wtmp		dw  0000h
p_cnt		db	00h		;ping counter

; Water Level storage area... hmmm that sounds military for some odd reason
wlevel		dw	0000h
water		db	00h

		org			0E000h
main    proc
init:
		cli
		mov		ax,0
		mov		ds,ax
		mov		ss,ax
		mov		es,ax
		mov		sp,7ffh
		
		mov		di,1000h
		mov		al,0
zeroing:
		mov		[di],al
		inc		di
		cmp		di,10ffh
		jbe		zeroing
init_ppi:	
		mov		ax,0
        mov     al,10000000b    ;configuration word for the 8255
                                ;both group A and B = mode 0
                                ;port A = input
                                ;port B = output
                                ;port C = output
        mov     dx,PPICTL
        out     dx,al         ;send the configuration word 
		mov		dx,0
		mov		cx,0
		
		mov		al,0ffh
		mov		dx,PORTC
		out		dx,al	

init_pic:
		lea	di,rtc
		mov	ds:[100h],di
		mov	ax,0
		mov	ds:[102h],ax

		mov	dx,ICW1
		mov	al,ICW1B
		out	dx,al

		mov	dx,ICW2
		mov	al,ICW2B
		out	dx,al

		mov	dx,ICW4
		mov	al,ICW4B
		out	dx,al

		mov	dx,OCW1
		mov	al,OCW1B
		out	dx,al
	
reset_wait:				; Just to give eth0 enough time to
		inc		cx 		; init internally
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
; LineCTL		
		mov		dx,PPPL
		mov		al,12h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,0D0h 
		out		dx,al
		mov		dx,PPD0H
		mov		al,00000000b
		out		dx,al
		
		mov		dx,PPPL
		mov		al,04h
		out		dx,al
		mov		dx,PPPH
		mov		al,01h
		out		dx,al
		mov		dx,PPD0L
		mov		al,01000000b
		out		dx,al
		mov		dx,PPD0H
		mov		al,00111001b
		out		dx,al	
poll:
		mov		al,02h
		mov		dx,LED
		out		dx,al
		
		sti
		cmp		time,30
		jae		send_status
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
		mov		wtmp,ax
		
		and		ax,0ff0fh
		cmp		ax,2304h
		jne		poll
		call	recv
		cmp		p_cnt,6
		je		water_level
		cmp		p_cnt,5
		je		brew
		cmp		p_cnt,4
		je		stop
		jmp		poll
send_status:
		mov		al,0ffh
		mov		dx,ADCON
		out		dx,al
		mov		dx,ADCON
		in		al,dx
		cmp		al,42h
		jbe		emptzor
		cmp		al,52h
		jbe		twozor
		cmp		al,6Bh
		jbe		threezor
		mov		water,40h
		jmp		continuzor
threezor:
		mov		water,30h
		jmp		continuzor
twozor:
		mov		water,20h
		jmp		continuzor
emptzor:
		mov		water,00h	
continuzor:	
		cli
		mov		time,0
		mov		al,water
		mov		data,al
		cmp		brewing_flag,0
	    je		status_set
		mov		al,DBREW
		mov		data+1,al
		jmp		status_go
status_set:
		mov		data+1,DIDLE
status_go:
		call	send
		jmp		poll
		
; Water Checking Sequence
; IS HERE!!		
water_level:
		mov		cl,0
blarg:
		mov		dx,ADCON
		mov		al,0ffh
		out		dx,al
		mov		dx,ADCON
		in		al,dx
		mov		data+1,al
		inc		cl
		cmp		cl,9
		jbe		blarg
		jmp		poll

; The Brewing Sequence
; IST HERE MEIN KINDER!
brew:
		cli
		mov		time,0
		mov		dx,ADCON
		mov		al,0ffh
		out		dx,al
		mov		dx,ADCON
		in		al,dx
		cmp		al,42h
		jbe		nope
ppi_init_2:	
		mov		ax,0
        mov     al,10000000b    ;configuration word for the 8255
                                ;both group A and B = mode 0
        mov     dx,PPICTL
        out     dx,al         ;send the configuration word 
		mov		brewing_flag,1
rawr:
		mov		dx,LED
		mov		al,09h
		out		dx,al
		
		mov		time,0
		mov		dx,ADCON
		mov		al,0ffh
		out		dx,al		;start ADC conversion

		push    cx
		mov		cx,100
x1:							; Many Thanks to
		dec		cx			; Mr. Markou for this section
		jnz		x1
		pop		cx		
		mov		dx,ADCON
		in		al,dx
		cmp		al,42h		
		jbe		fini		
		mov		dx,LED
		mov		al,0Bh
		out		dx,al		
		jmp		rawr
fini:
		mov		dx,LED
		mov		al,0Ah
		out		dx,al	
		sti
		cmp		time,60			;55 secs
		jbe		fini
		cli
		mov		time,0
		mov		data+1,DIDLE
		mov		dx,PORTC
		mov		al,0ffh
		out		dx,al	
		jmp		poll
nope:
		mov		data,0A0h
		mov		data+1,0A1h		;need to arrange this
		call	send
		jmp		poll
; The Stopping Squence
; Ici a*** de t*******
stop:
		cli
		mov		al,0ffh
		mov		dx,PORTC
		out		dx,al
		mov		brewing_flag,0
		jmp		poll
rtc:
		inc		tick
		cmp		tick,FREQ
		jbe		idone
		mov		tick,0
		inc		time
idone:
		iret
main    endp

recv	proc
		sti
		mov		time,0	
		mov		p_cnt,1
		call	send
recv_poll:
		cmp		time,5 ; 5 Seconds
		jae		shi
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
		mov		al,tmp		;data		
		and		ax,0f0ffh
		cmp		ax,2044h
		jne		recv_poll	
		inc		p_cnt	
		mov		data,0A0h
		mov		data+1,0A0h
		call	send		;ACK
		mov		time,0		;Reset the timer
		jmp		recv_poll
shi:						
		cli
		mov		al,p_cnt
		mov		time,0
		ret
recv	endp

send	proc
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
		mov		al,0c0h			;AND HERE
		;mov		al,data
		out		dx,al
		mov		dx,RXTX0H
		mov		al,0a8h			;HERE
		;mov		al,data+1
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
pad:		;padding
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
		mov		flag,1
		ret
send	endp

      org   0FFF0h
reset db    0eah    ;jmp
      dw    ROM     ;ip
      dw    0000h   ;cs
      end
