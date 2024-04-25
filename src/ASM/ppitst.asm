.model tiny
.code

ROM     equ     0E000h
PPI     equ     0A00h  ;depends on your Yx select of the 3-to-8
PORTA   equ     PPI+0
PORTB   equ     PPI+1
PORTC   equ     PPI+2
PPICTL  equ     PPI+3

        org     0800h
main    proc
init:
        mov     al,10000000b    ;configuration word for the 8255
                                ;both group A and B = mode 0
                                ;port A = input
                                ;port B = output
                                ;port C = input
        mov     dx,PPICTL
        out     dx,al         ;send the configuration word 
toggle_lo:
        nop
        nop
        mov     al,0            ;all port A lines to logic low
        mov     dx,PORTA
        out     dx,al
        nop
        nop
        mov     al,0            ;all port B lines to logic low
        mov     dx,PORTB
        out     dx,al
        nop
        nop
        mov     al,0            ;all port C lines to logic low
        mov     dx,PORTC
        out     dx,al

toggle_hi:
        nop
        nop
        mov     al,0ffh         ;now all port A lines to logic high
        mov     dx,PORTA
        out     dx,al
        nop
        nop
        mov     al,0ffh         ;now all port B lines to logic high
        mov     dx,PORTB
        out     dx,al
        nop
        nop
        mov     al,0ffh         ;now all port C lines to logic high
        mov     dx,PORTC
        out     dx,al
        
        mov     ds:[1000],al   ; bogus write to RAM for test reasons      
        jmp     toggle_lo      ;keep doing this forever

main    endp
		end
		