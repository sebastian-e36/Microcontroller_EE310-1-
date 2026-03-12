//-------------------------------
// Title: Heating and Cooling Control System
//
// Purpose: takes the measured temp and compares it ot the ref temp
// and turns the heater and fan on accordingly.
// Dependencies: AssemblyConfig.inc
// Compiler: MPLAB X IDE v6.30 with XC8 PIC Assembler v3.10
// Author: Sebastian Ventura
// OUTPUTS:PORTD.1 (Heating LED), PORTD.2 (Cooling LED)
// INPUTS: refTempInput (keypad reference temp), measuredTempInput (sensor temp)
// Versions:
//      V1.0: 03/08/2026 - First version
//-------------------------------

#include "AssemblyConfig.inc"
#include <xc.inc>


; PROGRAM INPUTS

#define measuredTempInput  45
#define refTempInput       50


; Definitions
    
#define SWITCH  LATD,2
#define LED0    PORTD,0
#define LED1    PORTD,1


; Program Constants

REG10 EQU 10h
REG11 EQU 11h
REG01 EQU 1h

refTemp      EQU 20h
measuredTemp EQU 21h
contReg      EQU 22h

refTemp_ones EQU 60h
refTemp_tens EQU 61h
refTemp_hund EQU 62h

measTemp_ones EQU 70h
measTemp_tens EQU 71h
measTemp_hund EQU 72h

tempVar EQU 30h


; Program Start

PSECT absdata,abs,ovrld

ORG 0x20

_START:
    BANKSEL TRISD
    CLRF    TRISD, A
    BANKSEL LATD
    CLRF    LATD, A

    MOVLW   refTempInput
    MOVWF   refTemp, A

    MOVLW   measuredTempInput
    MOVWF   measuredTemp, A

    CLRF    contReg, A

   
    ; Signed comparison: measuredTemp vs refTemp

    MOVF    refTemp, W, A
    SUBWF   measuredTemp, W, A

    ; Check if equal (Z=1)
    BZ      _EQUAL

    ; Signed: N XOR OV determines sign of result
    BTFSC   STATUS, 4, A
    BRA     _N_IS_SET
    BTFSC   STATUS, 3, A
    BRA     _LESS_THAN
    BRA     _GREATER_THAN

_N_IS_SET:
    BTFSC   STATUS, 3, A
    BRA     _GREATER_THAN
    BRA     _LESS_THAN

_GREATER_THAN:
    ; measuredTemp > refTemp: Turn on HEATING
    MOVLW   0x01
    MOVWF   contReg, A
    BANKSEL LATD
    BSF     LATD, 1, A
    BCF     LATD, 2, A
    BRA     _HEX_TO_DEC

_LESS_THAN:
    ; measuredTemp < refTemp: Turn on COOLING
    MOVLW   0x02
    MOVWF   contReg, A
    BANKSEL LATD
    BSF     LATD, 2, A
    BCF     LATD, 1, A
    BRA     _HEX_TO_DEC

_EQUAL:
    ; measuredTemp = refTemp: Turn off everything
    CLRF    contReg, A
    BANKSEL LATD
    BCF     LATD, 1, A
    BCF     LATD, 2, A
    BRA     _HEX_TO_DEC


; HEX TO DECIMAL CONVERSION (Subtraction Method)

_HEX_TO_DEC:
    ; --- Convert refTemp to decimal (regs 0x60-62) ---
    MOVF    refTemp, W, A
    MOVWF   tempVar, A

    ; Clear decimal registers using banked access
    MOVLB   0x00
    CLRF    refTemp_ones, 1
    CLRF    refTemp_tens, 1
    CLRF    refTemp_hund, 1

_REF_HUNDREDS:
    MOVLW   100
    CPFSLT  tempVar, A
    BRA     _REF_SUB_100
    BRA     _REF_TENS
_REF_SUB_100:
    MOVLW   100
    SUBWF   tempVar, F, A
    INCF    refTemp_hund, 1, 1
    BRA     _REF_HUNDREDS

_REF_TENS:
    MOVLW   10
    CPFSLT  tempVar, A
    BRA     _REF_SUB_10
    BRA     _REF_ONES
_REF_SUB_10:
    MOVLW   10
    SUBWF   tempVar, F, A
    INCF    refTemp_tens, 1, 1
    BRA     _REF_TENS

_REF_ONES:
    MOVF    tempVar, W, A
    MOVWF   refTemp_ones, 1

    ; --- Convert measuredTemp to decimal (regs 0x70-72) ---
    MOVF    measuredTemp, W, A
    MOVWF   tempVar, A
    BTFSS   measuredTemp, 7, A
    BRA     _MEAS_POS
    ; Negative: two's complement for absolute value
    COMF    tempVar, F, A
    INCF    tempVar, F, A

_MEAS_POS:
    MOVLB   0x00
    CLRF    measTemp_ones, 1
    CLRF    measTemp_tens, 1
    CLRF    measTemp_hund, 1

_MEAS_HUNDREDS:
    MOVLW   100
    CPFSLT  tempVar, A
    BRA     _MEAS_SUB_100
    BRA     _MEAS_TENS
_MEAS_SUB_100:
    MOVLW   100
    SUBWF   tempVar, F, A
    INCF    measTemp_hund, 1, 1
    BRA     _MEAS_HUNDREDS

_MEAS_TENS:
    MOVLW   10
    CPFSLT  tempVar, A
    BRA     _MEAS_SUB_10
    BRA     _MEAS_ONES
_MEAS_SUB_10:
    MOVLW   10
    SUBWF   tempVar, F, A
    INCF    measTemp_tens, 1, 1
    BRA     _MEAS_TENS

_MEAS_ONES:
    MOVF    tempVar, W, A
    MOVWF   measTemp_ones, 1

_LOOP:
    GOTO    _LOOP




