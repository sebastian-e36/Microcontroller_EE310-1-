; AssemblyConfig.inc
; Configuration bits for PIC18F46K42
; For use with XC8 PIC Assembler (pic-as) v3.10 in MPLAB X

PROCESSOR 18F46K42

; External Oscillator Selection
CONFIG FEXTOSC = LP

; Reset Oscillator Selection
CONFIG RSTOSC = EXTOSC

; Clock out Enable bit
CONFIG CLKOUTEN = OFF

; Clock Switch Enable bit
CONFIG CSWEN = ON

; Fail-Safe Clock Monitor Enable bit
CONFIG FCMEN = ON

; Master Clear Enable bit
CONFIG MCLRE = EXTMCLR

; Low-Power BOR Enable bit
CONFIG LPBOREN = OFF

; Brown-out Reset Enable bits
CONFIG BOREN = SBORDIS

; Brown-out Reset Voltage Selection bits
CONFIG BORV = VBOR_2P45

; Zero-Cross Detection Enable bit
CONFIG ZCD = OFF

; Peripheral Pin Select (PPS) 1-Way Lock bit
CONFIG PPS1WAY = ON

; Stack Overflow/Underflow Reset Enable bit
CONFIG STVREN = ON

; Debugger Enable bit
CONFIG DEBUG = OFF

; Extended Instruction Set Enable bit
CONFIG XINST = OFF

; WDT Operating Mode bits
CONFIG WDTE = OFF

; WDT Window Select bits
CONFIG WDTCWS = WDTCWS_7

; WDT Configuration Select bits
CONFIG WDTCPS = WDTCPS_31

; WDT Configuration Select bits
CONFIG WDTCCS = SC

; Configuration Register Write Protection bit
CONFIG WRTC = OFF

; Boot Block Write Protection bit
CONFIG WRTB = OFF

; Data EEPROM Write Protection bit
CONFIG WRTD = OFF

; Low Voltage Programming Enable bit
CONFIG LVP = ON

; Code Protection Block 0
CONFIG CP = OFF






