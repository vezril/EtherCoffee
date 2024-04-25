.model tiny
.code
EXTRN	newline:NEAR, outbyte:NEAR, outword:NEAR, getc:NEAR, outc:NEAR, outstr:NEAR
PPI     equ     200h   ;depends on your Yx select of the 3-to-8
PORTA   equ     PPI+0
PORTB   equ     PPI+1
PORTC   equ     PPI+2
PPICTL  equ     PPI+3

        org     800h
main    proc
init:
        mov     al,10000000b    ;configuration word for the 8255
                                ;both group A and B = mode 0
                                ;port A = output
                                ;port B = output
                                ;port C = output
        mov     dx,PPICTL
        out     dx,al         ;send the configuration word 
toggle_lo:
        mov     al,0            ;all port A lines to logic low
        mov     dx,PORTA
        out     dx,al
        mov     al,0            ;all port B lines to logic low
        mov     dx,PORTB
        out     dx,al
        mov     al,0            ;all port C lines to logic low
        mov     dx,PORTC
        out     dx,al
		lea		di,msg
		call	outstr
		call	getc
toggle_hi:
        mov     al,0ffh         ;now all port A lines to logic high
        mov     dx,PORTA
        out     dx,al
        mov     al,0ffh         ;now all port B lines to logic high
        mov     dx,PORTB
        out     dx,al
        mov     al,0ffh         ;now all port C lines to logic high
        mov     dx,PORTC
        out     dx,al  
		lea		di,msg
		call	outstr
		call	getc
        jmp     toggle_lo      ;keep doing this forever

main    endp

msg		db		"Press any key to continue...",04
      end
