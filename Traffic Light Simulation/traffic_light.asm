;
; traffic_light.asm
;
; Created           : 11/5/2025 1:55:03 PM
; Group Members     : Vanessa Gutierrez, Harrison Wier, Caleb Close
; Desc              : Simulate a traffic light w/ pedestrian crossing
; ---------------------------------------------------------


; Declare constants and global variables
; ---------------------------------------------------------
                ;     us  * (XTAL / scaler) - 1
.equ DELAY_MS    = 1000000 * (16 / 256.0) - 1


.equ NS_RED       = PB4
.equ NS_YELLOW    = PB3
.equ NS_GREEN     = PB2
.equ NS_WALK_GO   = PB1
.equ NS_WALK_STOP = PB0
.equ NS_WALK_BTN  = PD3      

.equ EW_RED       = PC1
.equ EW_YELLOW    = PC2
.equ EW_GREEN     = PC3
.equ EW_WALK_GO   = PC4
.equ EW_WALK_STOP = PC5
.equ EW_WALK_BTN  = PD2      

.equ GREEN_COUNT  = 6                                       ; How many seconds the green light will be on for                   
.equ YELLOW_COUNT = 3                                       ; How many seconds the yellow light will be on for


.def NS_WALK      = r18                                     ; Stores flag for NS walk button
.def EW_WALK      = r19                                     ; Stores flag for EW walk button
.def temp         = r20                                     ; Stores GREEN_COUNT & YELLOW_COUNT to perform operations
.def temp_delay   = r21                                     ; Used by the delay_1s function 


; Vector Table
; ---------------------------------------------------------
.org 0x0000                                                 ; Reset
        jmp         main

.org INT0addr                                               ; External Interrupt Request 0 (EW Button)
        jmp         btn_ew_isr                                  
                                                            
.org INT1addr                                               ; External Interrupt Request 1 (NS Button)
        jmp         btn_ns_isr                                  
                                                            
.org INT_VECTORS_SIZE                                       ; End vector table



; One-time configuration
; ---------------------------------------------------------
main:
          ; Initialize GPIO
          
          ; NS intersection lights set-up
          sbi       DDRB, NS_RED                            ; Set NS red LED to output mode                     
          cbi       PORTB, NS_RED                           ; Turn NS red light off
                            
          sbi       DDRB, NS_YELLOW                         ; Set NS yellow LED to output mode
          cbi       PORTB, NS_YELLOW                        ; Turn NS red light off 
                            
          sbi       DDRB, NS_GREEN                          ; Set NS green LED to output mode
          cbi       PORTB, NS_GREEN                         ; Turn NS red light off
                            
          sbi       DDRB, NS_WALK_GO                        ; Set NS white crosswalk LED to output mode
          cbi       PORTB, NS_WALK_GO                       ; Turn NS white crosswalk light off
                        
          sbi       DDRB, NS_WALK_STOP                      ; Set NS red crosswalk LED to output mode
          sbi       PORTB, NS_WALK_STOP                     ; Turn NS red crosswalk light on
        
          ; EW intersection lights set-up
          sbi       DDRC, EW_RED                            ; Set EW red LED to output mode                     
          cbi       PORTC, EW_RED                           ; Turn EW red light off
                                
          sbi       DDRC, EW_YELLOW                         ; Set EW yellow LED to output mode
          cbi       PORTC, EW_YELLOW                        ; Turn EW yellow light off
                            
          sbi       DDRC, EW_GREEN                          ; Set EW green LED to output mode
          cbi       PORTC, EW_GREEN                         ; Turn EW green light off
                          
          sbi       DDRC, EW_WALK_GO                        ; Set EW white crosswalk LED to output mode
          cbi       PORTC, EW_WALK_GO                       ; Turn EW white crosswalk light off
                          
          sbi       DDRC, EW_WALK_STOP                      ; Set EW red crosswalk LED to output mode
          sbi       PORTC, EW_WALK_STOP                     ; Turn EW red crosswalk light on
        

          ; NS button set-up
          cbi       DDRD, NS_WALK_BTN                       ; Set NS walk button to input mode
          sbi       PORTD, NS_WALK_BTN                      ; Pull-up

          ; EW button set-up
          cbi       DDRD, EW_WALK_BTN                       ; Set EW walk button to input mode              
          sbi       PORTD, EW_WALK_BTN                      ; Pull-up


          ; Interrupt set-up
          sbi       EIMSK, INT0                             ; External Interrupt 0 on pin D2
          sbi       EIMSK, INT1                             ; External Interrupt 1 on pin D3
          ldi       temp, (1 << ISC11) | (1 << ISC01)       ; Falling edge trigger
          sts       EICRA, temp                             

          sei                                               ; Turn global interrupts on


          ; Start of the Traffic Light Simulation
          ; ---------------------------------------------------------

          ; Set initial walk flags to 0 (no requests)
          clr       NS_WALK                 
          clr       EW_WALK

        
          ; All directions start on red (empty intersection)
          sbi       PORTB, NS_RED                           ; Turn NS red light on
          sbi       PORTC, EW_RED                           ; Turn EW red light on
          call      delay_1s                                ; Hold this cycle for 3 seconds
          call      delay_1s
          call      delay_1s

        

; Application main loop
; ---------------------------------------------------------
main_loop:

          ; NS green -> yellow -> red, crosswalk red

          ; NS green
          ; ---------------------------------------------------------
          cbi       PORTB, NS_YELLOW                        ; Turn NS yellow light off (just in case) 
          cbi       PORTB, NS_RED                           ; Turn NS red light off
          sbi       PORTB, NS_GREEN                         ; Turn NS green light on

          sbi       PORTB, NS_WALK_STOP                     ; Turn NS red crosswalk light on
          cbi       PORTB, NS_WALK_GO                       ; Turn NS white crosswalk light off

          ; Stop EW traffic
          sbi       PORTC, EW_RED                           ; Turn EW red light on (stop opposite flow of traffic)
          cbi       PORTC, EW_GREEN                         ; Turn EW green light off
          cbi       PORTC, EW_YELLOW                        ; Turn EW yellow light off (just in case)

          ; Check if pedestrian pressed EW walk button 
          tst       EW_WALK                                 ; If they did, enable the EW white crosswalk light on next red cycle
          breq      ns_green_walk_skip                      ; If they did not, keep the EW crosswalk light red

          cbi       PORTC, EW_WALK_STOP                     ; Turn EW red crosswalk light off
          sbi       PORTC, EW_WALK_GO                       ; Turn EW white crosswalk light on

ns_green_walk_skip:

          ldi       temp, GREEN_COUNT                       ; Set a temporary variable with the # of seconds NS green light should be on for
          call      ns_green_light                          ; NS green -> yellow
          call      ns_yellow_light                         ; NS yellow -> red


          ; EW green -> yellow -> red, crosswalk red

          ; EW green
          ; ---------------------------------------------------------
          cbi       PORTC, EW_YELLOW                        ; Turn EW yellow light off (just in case)
          cbi       PORTC, EW_RED                           ; Turn EW red light off
          sbi       PORTC, EW_GREEN                         ; Turn EW green light on

          sbi       PORTC, EW_WALK_STOP                     ; Turn EW red crosswalk light on
          cbi       PORTC, EW_WALK_GO                       ; Turn EW white crosswalk light off

          ; Stop NS traffic
          sbi       PORTB, NS_RED                           ; Turn NS red light on (stop opposite flow of traffic)
          cbi       PORTB, NS_GREEN                         ; Turn NS green light off 
          cbi       PORTB, NS_YELLOW                        ; Turn NS yellow light off (just in case)
           

          ; Check if pedestrian pressed NS walk button 
          tst       NS_WALK                                 ; If they did, enable the NS white crosswalk light on next red cycle
          breq      ew_green_walk_skip                      ; If they did not, keep the NS crosswalk light red

          cbi       PORTB, NS_WALK_STOP                     ; Turn EW red crosswalk light on
          sbi       PORTB, NS_WALK_GO                       ; Turn EW white crosswalk light off

ew_green_walk_skip:

          ldi       temp, GREEN_COUNT                       ; Set a temporary variable with the # of seconds EW green light should be on for
          call      ew_green_light                          ; EW green -> yellow
          call      ew_yellow_light                         ; EW yellow -> red


          rjmp      main_loop                               ; Repeat the Traffic Light cycle



; Functions
; ---------------------------------------------------------

; Function that turns NS green to yellow
; ---------------------------------------------------------
ns_green_light:

        ; Hold the green light for 6 seconds
ns_green_loop:
          call      delay_1s
          dec       temp
          brne      ns_green_loop

          ; NS yellow
          ; ---------------------------------------------------------
          cbi       PORTB, NS_GREEN           ; Turn NS green light off to transition from green -> yellow
          sbi       PORTB, NS_YELLOW          ; Turn NS yellow light on

          ldi       temp, YELLOW_COUNT        ; Set a temporary variable with the # of seconds NS yellow light should be on for

          ret


; Function that turns NS yellow to red
; ---------------------------------------------------------
ns_yellow_light:
    
          ; Check if EW walk was active during the green phase (flag is 1)
          tst       EW_WALK
          breq      ns_yellow_no_walk
    
          ; Blink EW Walk Light
ns_yellow_loop:
          cbi       PORTC, EW_WALK_GO                       ; Turn off EW white crosswalk light
          call      delay_1s                                ; Keept light off for 1 second
          sbi       PORTC, EW_WALK_GO                       ; Turn on EW white crosswalk light
          call      delay_1s                                ; Keept light off for 1 second
          dec       temp                                    ; Continue blinking until yellow light is done
          
          brne      ns_yellow_loop                    

          ; Reset EW walk light to red and clear flag
          cbi       PORTC, EW_WALK_GO                       ; Turn off EW white crosswalk light 
          sbi       PORTC, EW_WALK_STOP                     ; Turn on EW red crosswalk light
          clr       EW_WALK                                 ; Clear the EW walk flag so button input can be freshily read
          rjmp      ns_yellow_end
    
          ; If the EW walk button was not pushed
ns_yellow_no_walk:
          ; Keep the NS yellow light on as normal (3 seconds)
ns_yellow_delay_loop:
          call      delay_1s                        
          dec       temp
          brne      ns_yellow_delay_loop
    
ns_yellow_end:
          cbi       PORTB, NS_YELLOW                        ; Turn NS yellow light off
          call      clear_intersection                      ; Turn all lights off in both directions to clear the intersection

          ret


; Function that turns EW green to yellow
; ---------------------------------------------------------
ew_green_light:

        ; Hold the green light for GREEN_COUNT seconds
ew_green_loop:
          call      delay_1s
          dec       temp
          brne      ew_green_loop


          ; EW yellow transition
          cbi       PORTC, EW_GREEN                         ; Turn NS green light off to transition from green -> yellow
          sbi       PORTC, EW_YELLOW                        ; Turn NS yellow light on

          ldi       temp, YELLOW_COUNT                      ; Set a temporary variable with the # of seconds NS yellow light should be on for

          ret


; Function that turns EW yellow to red
; ---------------------------------------------------------
ew_yellow_light:
    
          ; Check if NS walk was active during the green phase (flag is 1)
          tst       NS_WALK
          breq      ew_yellow_no_walk
    
          ; Blink NS Walk Light
ew_yellow_blink_loop:
          ; Blink white walk light (NS)
          cbi       PORTB, NS_WALK_GO                       ; Turn off NS white crosswalk light
          call      delay_1s                                ; Keept light off for 1 second
          sbi       PORTB, NS_WALK_GO                       ; Turn on NS white crosswalk light
          call      delay_1s                                ; Keept light off for 1 second
          dec       temp                                    ; Continue blinking until yellow light is done
          brne      ew_yellow_blink_loop

          ; Reset NS walk light to red and clear flag
          cbi       PORTB, NS_WALK_GO                       ; Turn off NS white crosswalk light 
          sbi       PORTB, NS_WALK_STOP                     ; Turn on NS red crosswalk light  
          clr       NS_WALK                                 ; Clear the NS walk flag so button input can be freshily read  
          rjmp      ew_yellow_end                           
    
          ; If the NS walk button was not pushed
ew_yellow_no_walk:
          ; Keep the EW yellow light on as normal (3 seconds)
ew_yellow_delay_loop:
          call      delay_1s                                     
          dec       temp
          brne      ew_yellow_delay_loop
    
ew_yellow_end:
          cbi       PORTC, EW_YELLOW                        ; Turn EW yellow light off
          call      clear_intersection                      ; Turn all lights off in both directions to clear the intersection

          ret


; Function that clears the intersection
; ---------------------------------------------------------
clear_intersection:
        ; Set the red lights of both directions to clear the intersection.
        ; This is needed so no accidents (vehicular and/or pedestrian) occur when switching one side from red/green and the other to green/red.
        ; ---------------------------------------------------------
        sbi         PORTB, NS_RED                           ; Turn NS red light on
        sbi         PORTC, EW_RED                           ; Turn EW red light on
        call        delay_1s                                ; Hold this cycle for 3 seconds
        call        delay_1s
        call        delay_1s

        ret


; Delay function
; ---------------------------------------------------------
delay_1s:
          ; 1. Load TCNT1H:TCNT1L with initial count
          clr       temp_delay
          sts       TCNT1H, temp_delay
          sts       TCNT1L, temp_delay

          ; 2. Load OCR1AH:OCR1AL with stop count
          ldi       temp_delay, high(DELAY_MS)
          sts       OCR1AH, temp_delay
          ldi       temp_delay, low(DELAY_MS)
          sts       OCR1AL, temp_delay

          ; 3. Load TCCR1A & TCCR1B
          clr       temp_delay
          sts       TCCR1A, temp_delay
          ldi       temp_delay, (1 << WGM12)|(1 << CS12)
          sts       TCCR1B, temp_delay

          ; 4. Monitor OCF1A flag in TIFR1
monitor_OCF1A:
          sbis      TIFR1, OCF1A
          rjmp      monitor_OCF1A

          ; 5. Stop timer by clearing clock (clear TCCR1B)
          clr       temp_delay
          sts       TCCR1B, temp_delay

          ; 6. Clear OCF1A flag – write a 1 to OCF1A bit in TIFR1
          ldi       temp_delay, (1 << OCF1A)
          out       TIFR1, temp_delay

          ret                              


; Interrupts
; ---------------------------------------------------------

; Handle NS crosswalk button press
; ---------------------------------------------------------
btn_ns_isr:
          ldi       NS_WALK, 1                             ; Sets the flag for NS walk request
          reti

; Handle EW crosswalk button press
; ---------------------------------------------------------
btn_ew_isr:
          ldi       EW_WALK, 1                             ; Sets the flag for EW walk request
          reti