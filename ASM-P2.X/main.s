PROCESSOR 18F57Q43
    
; Includes SFRs, macros and memory sections
#include <xc.inc>   

; This is data memory (RAM)
PSECT var,class=RAM,space=SPACE_DATA,noexec
Time1: DS 1	    ; Time1 variable
Time2: DS 1	    ; Time2 variable

; Vector interrupt table
PSECT resetVect,class=CODE,space=SPACE_CODE,reloc=2
    
resetVect:	; 

    goto main	; Goto main program

; This is program memory (ROM)
PSECT code,class=CODE,space=SPACE_CODE,reloc=2

main:
    
    call GPIO_Config ; Call subroutine to configure GPIO
    
    movlb 4	    ; Bank 4 (SFRs are located in bank 4)

Read_RB4:           ; Is switch on RB4 closed?
 
    btfsc PORTB,4,1    ; if RB4='0', skip next instruction
    goto RB4_opened    ; Jump to label RB4_opened (RB4='1')
    goto RB4_closed    ; Jump to label RB4_closed (RB4='0')
    
; Slow blink on RF3
RB4_closed:
    movlw 00h	    
    movwf LATF,1    ; Clear RF3 (turn on LED)
    call Delay1     ; Jump to Delay1 subroutine
           
    movlw 08h
    movwf LATF,1    ; Set RF3 (turn off LED)
    call Delay1     ; Jump to Delay1 subroutine
    goto Read_RB4   ; Read RB4 switch

; Fast blink on RF3
RB4_opened:
    movlw 00h	    
    movwf LATF,1    ; Clear RF3 (turn on LED)
    call Delay2     ; Jump to Delay2 subroutine
           
    movlw 08h
    movwf LATF,1    ; Set RF3 (turn off LED)
    call Delay2     ; Jump to Delay2 subroutine
    goto Read_RB4   ; Read RB4 switch
    
; Subroutine to configure GPIO
GPIO_Config:
    movlb 4	    ; Bank 4 (SFRs are located in bank 4)
    
    movlw 10h	    
    movwf TRISB,1   ; RB4 configured as input; RB7:RB5 and RB3:RB0 as outputs (not used)
    
    movlw 00h	    
    movwf TRISA,1   ; PORTA configured as output (not used)
    movwf TRISC,1   ; PORTC configured as output (not used)
    movwf TRISD,1   ; PORTD configured as output (not used)
    movwf TRISE,1   ; PORTE configured as output (not used)
    movwf TRISF,1   ; RF3 configured as output; RF7:RF4 and RF2:RF0 as outputs (not used)

    movlw 00h	    
    movwf LATA,1    ; Clear port A
    movwf LATC,1    ; Clear port C
    movwf LATD,1    ; Clear port D
    movwf LATE,1    ; Clear port E
    movlw 08h
    movwf LATF,1    ; Set RF3 = 1 (turn off LED); Clear RF7:RF4, RF2:RF0
    
    movlw 10h	    
    movwf WPUB,1    ; Rpull-up enabled on RB4; pull-ups on RB7:RB5 and RB3:RB0 disabled
    
    movlw 00h	    
    movwf WPUA,1    ; Rpull-up on portA disabled
    movwf WPUC,1    ; Rpull-up on portC disabled
    movwf WPUD,1    ; Rpull-up on portD disabled
    movwf WPUE,1    ; Rpull-up on portE disabled
    movwf WPUF,1    ; Rpull-up on portF disabled
    
    clrf ANSELA,1   ; PortA pins as digital I/O
    clrf ANSELB,1   ; PortB pins as digital I/O
    clrf ANSELC,1   ; PortC pins as digital I/O
    clrf ANSELD,1   ; PortD pins as digital I/O
    clrf ANSELE,1   ; PortE pins as digital I/O
    clrf ANSELF,1   ; PortF pins as digital I/O
    
    return	    ; Return from subroutine

; Delay1 subroutine
Delay1:
    movlb 06h        ; Bank 6
      
    movlw 9Fh       
    movwf Time1,1    ; Store 9Fh in Time1
    
Decre_Time1_Delay1:
    dcfsnz Time1,1,1 ; Decrement Time1
    goto Delay1_end  ; Jump to end if Time1=0
    
    movlw 0FFh       ; Store FFh in Time2
    movwf Time2,1
    
Decre_Time2_Delay1:
    decfsz Time2,1,1 ; Decrement Time2, skip if = 0
    goto Decre_Time2_Delay1       
    goto Decre_Time1_Delay1 ; Repeat

Delay1_end:    
    movlb 4
    return            ; Return to main program

; Delay2 subroutine
Delay2:
    movlb 06h        ; Bank 6
      
    movlw 3Fh       
    movwf Time1,1    ; Store 3Fh in Time1
    
Decre_Time1_Delay2:
    dcfsnz Time1,1,1 ; Decrement Time1
    goto Delay2_end  ; Jump to end if Time1=0
    
    movlw 0FFh       ; Store FFh in Time2
    movwf Time2,1
    
Decre_Time2_Delay2:
    decfsz Time2,1,1 ; Decrement Time2, skip if = 0
    goto Decre_Time2_Delay2       
    goto Decre_Time1_Delay2 ; Repeat

Delay2_end:    
    movlb 4
    return            ; Return to main program
        
END resetVect         ; End program