*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

            ORG RAMStart
; Insert here your data definition.
output_string   DS.B  16     ; allocate 16 bytes at the address output_string
input_string    FCC   "this.is My string. hI"  ; make a string in memory
test_character  FCC "s"
middle_value      EQU $60    ; value between low and high
change_value    EQU $20
string_length   DS.B  1     ; one byte to store the string length
test_count      DS.B  1     ; one byte to store the count of the test_character
temp_letter     DS.B  2     ;two bytes for the temporary letter



; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:
      
            LDAA  #$00        ; store the value 16 (the length of the string)
            STAA  string_length
            
            LDX   #input_string
            LDY   #output_string

innerLoop:    
            LDAB  1, x+          ;Load next letter
            
            BRA   FOURNormalText      ;Branch always to chosen Routine (choose Routine here) 
            

ONELowerCase:                     ;Make All lowercase
            CMPB #$20                ;check if loaded letter is a space
            BEQ comeBack             ;if so write it to output
            CMPB #$2E                ;check if loaded letter is a fullstop
            BEQ comeBack             ;if so write it to output
            CMPB #middle_value        ;compare letter with middle value 
            BLO makeLower            ;make letter lowercase if higher
            BRA comeBack             ;write the final letter to ouput

TWOmakeHigher:                    ;Make all upercase
            CMPB #$20                ;check if loaded letter is a space
            BEQ comeBack             ;if so write it to output
            CMPB #$2E                ;check if loaded letter is a fullstop
            BEQ comeBack             ;if so write it to output
            CMPB #middle_value        ;compare letter to middle value
            BHI makeHigher           ;make letter uppercase if lowercase
            BRA comeBack
     
THREEfirstLetter:                    ;Make the first Letter of each word uppercase
            CMPA #$00                ;Test if the count of the string length is at the start (very first letter)
            BEQ TWOmakeHigher         ;If so send to 2nd function to test if it is Uppercase
            CMPB #$20                ;check if letter is a space
            BEQ newWord              ;If so go to new word function
            CMPB #$2E                ;Check for fullStop
            BEQ comeBack             ;Return if fullstop
            CMPB #middle_value        ;Check if uppercase
            BLO makeLower            ;make all the other letters that are uppercase into lowercase
            BRA comeBack             ;return
            
FOURNormalText:                     ;Make the First letter of each sentance uppercase
            CMPA #$00                 ;Check First letter
            BEQ TWOmakeHigher          ;Make sure its uppercase
            CMPB #$2E                 ;Check if letter is a fullstop
            BEQ checkForSpace         ;If so go to function to make next letter a space and the letter after that uppercase
            CMPB #$20                 ;Check if random Space
            BEQ comeBack              ;Return if true
            CMPB #middle_value         ;Check if other letters are lowercase
            BLO makeLower             ;Make lowercase if not
            BRA comeBack

            
comeBack:                        ;Write to output
            
            CMPB  #$5A                  ;Compare the letters left with 0
            BEQ  finish               ;If 0 finish
            STAB  0, y                ;Store the B value in Y
            INCA                      ;Decrease letter count
            INY                       ;Move to next letter in output string
            BRA innerLoop             ;Return to start



makeLower:          
            ADDB #$20    ;Add 20 to the ascii value of the uppercase letter to make it lowercase
            BRA comeBack             ;return
            
makeHigher:
            SUBB #change_value     ;Subtract 20 from the ascii value of the lowercase letter to make it uppercase
            BRA comeBack             ;return
         
newWord:                         ;Make the first letter after a space an Uppercase letter
            BSR nextCharacter      ;Store the current Character and move to the next
            LDAB 1,x+              ;load next letter
            CMPB #middle_value      ;Compare to middle value
            BHI makeHigher         ;make higher if necesary
            BRA comeBack           ;return
              

checkForSpace:                       ;Check the next letter for a space and add one if none
            LDAB 1,x+                     ;Load the next value following the fullstop
            CMPB #$20                      ; check if the next value is a space
            BNE space_after_fullstop      ;If it is not then go to function to make a space in output
            BSR nextCharacter             ;If there is load the space into output
            LDAB 1,x+                     ;Load the next Letter 
            BRA TWOmakeHigher              ;Check if it is uppercase and make it Uppercase if it is not


space_after_fullstop:                ;Insert a space intoput string
            PSHB
            LDAB #$20                     ;Load a space into register B
            BSR nextCharacter             ;store into output
            PULB
            INCA
                                  
            BRA TWOmakeHigher              ;Check if higher and make higher if not

nextCharacter:                       ;Quick store in output string without returning to start
            STAB 0,y                      ;Store in ouput string y
            INY                           ;Increment the ouput string
            DECA                          ;Decrease letter count
            RTS                           ;return from subroutine
                                  
                  
            
finish:


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
