;
; studio.asm
;
; Created  : 9/22/2025 1:45:15 PM
; Author   : hazel
; Desc	 : Demo & Setup of Microchip Studio
;------------------------------------------------------------------

.equ VarX = 0x0100                      ; compiler directive that allows us to store address 0x0100 as a variable

main: 

          ldi       r16, 42             ; establish variable x
          sts       VarX, r16           ; and assign 42

          lds       r0, VarX            ; load variable x
          ldi       r16, 0x0D           ; load 13
          sub       r0, r16             ; x -= 13

          sts       VarX, r0            ; store new value of x

end_main:
          rjmp      end_main

