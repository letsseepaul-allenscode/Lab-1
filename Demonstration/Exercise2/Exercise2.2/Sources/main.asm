;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*                                                               *
;*          Print the numbers 0-9 onto 7-seg and LEDs            *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

  ORG RAMStart


number_lookup fcb $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F ;0,1,2,3,4,5,6,7,8,9 in HEX
num_of_elements equ 10 
DIG4ON equ $07

; variable/data section



 ; Insert here your data definition.
Counter     DS.W 1
FiboRes     DS.W 1


; code section
            ORG   ROMStart


Entry:
_Startup:

       LDS   #RAMEnd+1       ; initialize the stack pointer
       
configure:
       ldaa #$FF
       staa DDRB    ;Port B as output
       staa DDRJ    ;Port J as output (LEDs)
       ldaa #00
       staa PTJ
       ldaa #$0F
       staa DDRP

mainloop:
        
        movb #DIG4ON, PTP   ; enable the fourth 7-seg
        ;ldy #0
        ldaa #0
        ldy #num_of_elements
        bsr send_led
        bra finish
        ;bra mainloop
      

send_led:             
        ldx #number_lookup
             ; Load the lookup table with HEX values
        ldab a, x             ; Get the value from the look up table and increment to the next number
        stab PORTB            ; Send the value to the 7-seg
        bsr delay
        inca
        ;iny             ; Delay to ensure ghosting does not occur
           ;Load A with the length of the string
        dey
        bne send_led
           rts
           
; Make the delay equal to 1s, about 24M e-cycles  
; 25 * 48000 * 20 = 24000000
delay:
            ldab #20
loop_outer: 
            ldx #48000 ;(2 E-cycles) load the value of 60 000 into index register x
	loop_inner:   ; 25 e-cycles, when it reaches the last line it is 28 e-cycles
           psha ; 2 E-cycles
           pula ; 3 E-cycles
           psha 
           pula 
           psha
           pula 
           psha 
           pula 
	   nop  ; 1 E-cycle  
	   nop
           dbne x, loop_inner ; 3 E-cycles
	 
           dbne b, loop_outer ; 3 E-cycles
            rts 
            
 finish:
 
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
