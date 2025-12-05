# Traffic Light Simulation Project
A class project intended to simulate an intersection made in AVR Assembly on an Arduino UNO3 with an ATMega328p microcontroller.

## Scenario
There are 2 streets - one going North/South and the other going East/West. Create a simulation where if North/South is green, make East/West red - and vice versa. Also implement crosswalks for both directions that remain red when no pedestrian pushes the button to request a walk. If the pedestrian does press the button, change the crosswalk light on the next red cycle to indicate that the person can walk. Extra Credit: Blink the walk light to indicate that the person should finish crossing as the traffic light is going to change to red soon.

## Configuration
NS Red LED - Pin B4 <br>
NS Yellow LED - Pin B3 <br>
NS Green LED - Pin B2 <br>
NS Walk LED - Pin B1 <br>
NS No Walk LED - Pin B0 <br>
NS Walk Button - Pin D3 <br>

EW Red LED - Pin C1 <br>
EW Yellow LED - Pin C2 <br>
EW Green LED - Pin C3 <br>
EW Walk LED - Pin C4 <br>
EW No Walk LED - Pin C5 <br>
EW Walk Button - Pin D2 <br>

<br> Timer 1 Mode: CTC <br>

Clock Prescaler: 62,499 (1,000,000 * (16 / 256.0) - 1) <br>

Interrupts used: External Interrupt Requests 0 & 1 <br>
