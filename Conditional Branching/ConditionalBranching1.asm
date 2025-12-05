;
; ConditionalBranching1.asm
;
; Created        : 9/24/2025 1:40:13 PM
; Name           : Vanessa Gutierrez
; Course         : Computer Organization & Assembly Language - CDA 3104
; Assignment Name: Conditional Branching with if / else if / else
; Desc           : Program that branches if a value is less than 25
;-----------------------------------------------------------

main: 
          LDI       R16, 10             ; set a value for x
          CPI       R16, 50             ; is x == 50?
          BRLO      X_LT_50             ; if x < 50, branch to else if (x > 25)
          BREQ      X_LT_50             ; if x == 50, branch to else if (x > 25)
          LDI       R17, 3              ; if x > 50, y = 3
          RJMP      end_main            ; break

X_LT_50:
          CPI       R16, 24             ; is x == 24?
          BRLO      X_LT_24             ; if x < 24, branch to else
          LDI       R17, 2              ; 50 <= x <= 25 so set y = 2
          RJMP      end_main            ; break

X_LT_24:
          LDI       R17, 1              ; x < 25 so set y = 1

end_main:
          RJMP      end_main            ; end of program