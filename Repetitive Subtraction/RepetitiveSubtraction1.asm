;
; RepetitiveSubtraction1.asm
;
; Created        : 9/24/2025 1:40:13 PM
; Name           : Vanessa Gutierrez
; Course         : Computer Organization & Assembly Language - CDA 3104
; Assignment Name: Repetitive Subtraction with a while Structure
; Desc           : Program that uses a while loop to subtract 2 from a number until it becomes less than 10
;-----------------------------------------------------------

main: 
          LDI       R16, 18             ; int x = 18
          MOV       R5, R16
          CPI       R16, 10             ; is x >= 10?
          BRSH      x_gtet_10           ; if yes, go to while loop
          RJMP      end_main            ; if no, end program

x_gtet_10:                              ; while loop
          DEC       R16                 ; x--
          DEC       R16                 ; x--
          CPI       R16, 10             ; is x >= 10?
          BRLO      end_main            ; if no, exit while loop
          RJMP      x_gtet_10           ; if yes, stay in while loop


end_main: 
          RJMP      end_main            ; end program