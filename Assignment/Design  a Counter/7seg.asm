//-------------------------------
// Title: Design a Counter
//
// Purpose: Lights up a 7 segment counter that will 
// either increase or decrease the number dsipayed depending on
// what number is pressed
// Dependencies: xc.inc
// Compiler: MPLAB X IDE v6.30 with XC8 PIC Assembler v3.10
// Author: Sebastian Ventura
// OUTPUTS RD0, RD1, RD2, RD3, RD4, RD5, RD6
// INPUTS: RBO - switch A, RB1 - Switch B, RB0+RB1 - Reset
// Versions:
//      V1.0: 04/02/2026 - First version
//-------------------------------
#include <xc.inc>
#include "7segcon.inc"
 
; ----- Variable Definitions -----
PSECT udata_acs
COUNT:      DS  1
DELAY1:     DS  1
DELAY2:     DS  1
DELAY3:     DS  1
SW_STATE:   DS  1
 
;*******************************************************************************
; RESET VECTOR
;*******************************************************************************
PSECT resetVec, class=CODE, reloc=2
resetVec:
    goto    MAIN
 
;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************
PSECT code
MAIN:
    ;------------------------------------------------------------------
    ; Initialize PORTD as digital output (7-segment display)
    ; Explicit banksel for EVERY register to avoid banking bugs
    ;------------------------------------------------------------------
    banksel ANSELD
    clrf    ANSELD, B       ; All PORTD pins digital
 
    banksel TRISD
    clrf    TRISD, B        ; All PORTD pins as output
 
    banksel LATD
    clrf    LATD, B         ; Clear PORTD outputs
 
    ;------------------------------------------------------------------
    ; Initialize PORTB RB0, RB1 as digital inputs with pull-ups
    ;------------------------------------------------------------------
    banksel ANSELB
    clrf    ANSELB, B       ; All PORTB pins digital
 
    banksel TRISB
    movlw   0xFF
    movwf   TRISB, B        ; All PORTB pins as input
 
    banksel WPUB
    movlw   0x03
    movwf   WPUB, B         ; Enable weak pull-ups on RB0, RB1
 
    ;------------------------------------------------------------------
    ; Initialize counter to 0 and display it
    ;------------------------------------------------------------------
    banksel COUNT
    clrf    COUNT, B        ; Start at 0
    call    DISPLAY_7SEG    ; Show initial 0
 
;*******************************************************************************
; MAIN LOOP
;*******************************************************************************
MAIN_LOOP:
    banksel PORTB
    movf    PORTB, W, B     ; Read PORTB
    andlw   0x03            ; Keep only RB0, RB1
    banksel SW_STATE
    movwf   SW_STATE, B     ; Save switch state
 
    ; Both pressed? (both LOW -> 0x00)
    movf    SW_STATE, W, B
    sublw   0x00
    bz      DO_RESET
 
    ; Only Switch A pressed? (RB0=0, RB1=1 -> 0x02)
    movf    SW_STATE, W, B
    sublw   0x02
    bz      DO_COUNT_UP
 
    ; Only Switch B pressed? (RB0=1, RB1=0 -> 0x01)
    movf    SW_STATE, W, B
    sublw   0x01
    bz      DO_COUNT_DOWN
 
    ; Neither pressed -> hold display
    goto    MAIN_LOOP
 
;*******************************************************************************
; DO_RESET
;*******************************************************************************
DO_RESET:
    banksel COUNT
    clrf    COUNT, B
    call    DISPLAY_7SEG
    call    DELAY_500MS
    goto    MAIN_LOOP
 
;*******************************************************************************
; DO_COUNT_UP
;*******************************************************************************
DO_COUNT_UP:
    banksel COUNT
    incf    COUNT, F, B
    movlw   0x10
    cpfseq  COUNT, B
    goto    SKIP_WRAP_UP
    clrf    COUNT, B
SKIP_WRAP_UP:
    call    DISPLAY_7SEG
    call    DELAY_500MS
    goto    MAIN_LOOP
 
;*******************************************************************************
; DO_COUNT_DOWN
;*******************************************************************************
DO_COUNT_DOWN:
    banksel COUNT
    movf    COUNT, W, B
    bz      WRAP_DOWN
    decf    COUNT, F, B
    goto    SKIP_WRAP_DOWN
WRAP_DOWN:
    movlw   0x0F
    movwf   COUNT, B
SKIP_WRAP_DOWN:
    call    DISPLAY_7SEG
    call    DELAY_500MS
    goto    MAIN_LOOP
 
;*******************************************************************************
; DISPLAY_7SEG - Table Pointer lookup and output to LATD
;*******************************************************************************
DISPLAY_7SEG:
    movlw   low highword(SEGMENT_TABLE)
    movwf   TBLPTRU, A
    movlw   high(SEGMENT_TABLE)
    movwf   TBLPTRH, A
    movlw   low(SEGMENT_TABLE)
    movwf   TBLPTRL, A
 
    banksel COUNT
    movf    COUNT, W, B
    addwf   TBLPTRL, F, A
    movlw   0
    addwfc  TBLPTRH, F, A
    addwfc  TBLPTRU, F, A
 
    tblrd*
 
    movf    TABLAT, W, A
 
    banksel LATD
    movwf   LATD, B
 
    return
 
;*******************************************************************************
; DELAY_500MS - Nested loop delay (tuned for 64 MHz oscillator)
;*******************************************************************************
DELAY_500MS:
    banksel DELAY1
    movlw   20
    movwf   DELAY1, B
DELAY_OUTER:
    movlw   200
    movwf   DELAY2, B
DELAY_MIDDLE:
    movlw   250
    movwf   DELAY3, B
DELAY_INNER:
    nop
    nop
    nop
    nop
    decfsz  DELAY3, F, B
    goto    DELAY_INNER
    decfsz  DELAY2, F, B
    goto    DELAY_MIDDLE
    decfsz  DELAY1, F, B
    goto    DELAY_OUTER
    return
 
;*******************************************************************************
; 7-SEGMENT LOOKUP TABLE
;*******************************************************************************
PSECT tableData, class=CONST, reloc=2
SEGMENT_TABLE:
    db  0x3F    ; 0
    db  0x06    ; 1
    db  0x5B    ; 2
    db  0x4F    ; 3
    db  0x66    ; 4
    db  0x6D    ; 5
    db  0x7D    ; 6
    db  0x07    ; 7
    db  0x7F    ; 8
    db  0x6F    ; 9
    db  0x77    ; A
    db  0x7C    ; B
    db  0x39    ; C
    db  0x5E    ; D
    db  0x79    ; E
    db  0x71    ; F
 
    end


