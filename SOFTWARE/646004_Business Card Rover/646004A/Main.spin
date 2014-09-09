{{               
********************************************************
* Marketing Rover                                      *
* Author: David Gitz                                   *
* Copyright (c) 2014 David Gitz/FAST Robotics          *     
********************************************************

TODO
 - 
   
{{
TARGET:
  - Parallax Quickstart and Robot Shield (FR# 810001)
PURPOSE:
  - 
}}
{{
SETUP:
}}
{{
INDICATOR LIGHTS
LED1: On During Startup, Off otherwise
LED2: Blinking if Running, On in CLI Mode, Off if Not Running
LED4: On if Error, Off otherwise.
}}
{{
LOG:
  DPG 30-AUG-2014.  Created Program.  
 
  
}}
CON

' Timing             
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000 
  
' ASCII Constants
  CR = 13
  LF = 10
  SPACE = 32
  PERIOD = 46
  COMMA =  44
  TAB = 9

 'Loop Rates
  FAST_LOOP = 1 '100 Hz, 10 mS
  MEDIUM_LOOP = 10 '10 Hz, 50 mS
  SLOW_LOOP = 100 '1 Hz, 200 mS

  PRIORITY_HIGH = 0
  PRIORITY_MEDIUM = 1
  PRIORITY_LOW = 2  

  ' UART Definitions
    debug_port = 0
    com_port = 1
      
  ' Hardware Pins************************************
  PINNOTUSED = -1                    

  ' UART Pins
  usbtx = 30  'USB TX Line
  usbrx = 31  'USB RX Line
  comtx = 8  'Robot Shield TX Line, FIX
  comrx = 7  'Robot Shield RX Line, FIX

' Led's

  LED4 = 17
  LED3 = 18
  LED2 = 19
  LED1 = 20

' Motor Out Pin: Set to -1 if not used
  SERVO1 = 16
  SERVO2 = 15
  SERVO3 = 14
  SERVO4 = 13

  'ADC Pins/Misc
  ADCuartPin = 21
  ADCclkPin = 22
  ADCcsPin = 23


  'Analog Sensors
  AnalogSense1 = 0
  AnalogSense2 = 1
  AnalogSense3 = 2
  AnalogSense4 = 3
  AnalogSense5 = 4
  AnalogSense6 = 5
  AnalogSense7 = 6
  AnalogSense8 = 7

 'GPIO Pin Definitions
  GPIO1 = 6
  GPIO2 = 5
  GPIO3 = 4
  GPIO4 = 3
  GPIO5 = 2

  'US Pin Definitions.  These are just more GPIO
  US1 = 13
  US2 = 12
  US3 = 11
  US4 = 10

  'SD Card Pin Definitions
  SD_DO = 24
  SD_SCLK = 25
  SD_DI = 26
  SD_CS = 27

' ****************************************************  

  'ADC Definitions
  ADC_VOLTAGE_CONVERSION = 18   
  ADC_LOWER_THRESHOLD = 100  'Threshold for converting Analog Input to Boolean states.  Below this is FALSE.
  ADC_UPPER_THRESHOLD = 3900   'Threshold for converting Analog Input to Boolean states.  Above this is TRUE.
  ADC_MIN_VALUE = 0
  ADC_MAX_VALUE = 4096
  ADCmode = $00FF  
  
 'PWM/Motor Definitions

  PWM_MIN_VALUE = 1000
  PWM_MAX_VALUE = 2000
  PWM_NEUTRAL_VALUE = 1500 


  'FAST Protocol Definitions
  SD = $24
  ED = $2A
  'Message/Sub-Message Type Definitions
  MT_ERROR = $01
  SMT_NOERROR = $01


  'Value Type Definitions
  VT_NODATA = $FF
  VT_1INT = $01
   
  ' User Pin Definitions
  Arm_Pin = GPIO1
  Startup_LED = LED1
  Run_LED = LED2
  Armed_LED = LED3
  Error_LED = LED4

  'Ultrasonic Sensor Definitions
  PING_FRONT = GPIO1
  PING_LEFT = GPIO2
  PING_RIGHT = GPIO3
  

  'Obstacle Detecion/Avoidance Stuff
  BEYONDFAR = 100
  FAR = 60
  MID = 10
  GRIDSIZE = 7


OBJ
  uart:         "pcFullDuplexSerial4FC"
  pwmout:       "PWM_32_v4"
  util:         "Util"
  adc:          "MCP3208"
  timer:        "Timer"
  str:          "STRINGS2"
  sdcard:           "fsrw"
  ping:         "ping"
  math:         "spin_trigpack"

VAR
  'Program Variables
  byte cogsused

  'Timing Variables
  long wait_mS
  long elapsedtime
  long slow_loop_count
  long medium_loop_count
  long fast_loop_count
  byte prioritylevel
  word ontime
  long armedtimer
  byte armedstart

  'UART Variables
  long stack[10]  
  byte rxbyte,rxinit  
  byte tempbyte
  byte tempstr1[50]
  byte  stringbuffer[100]
  byte comrxbuffer[100] 
  

  'Motor Variables
  byte Armed

  'Obstacle Detection/Avoidance Variables
  long front_distance
  long left_distance
  long right_distance
  long occupancy_grid[GRIDSIZE*GRIDSIZE]
  long com_x
  long com_y
  long target_x
  long target_y
  long target_theta
  long target_speed
  
  'SD Card Variables
  byte tbuf[20]
  byte bigbuf[256]

PUB init | i,j,sum, tempstr, temp1,fileerror
  
  front_distance := 0
  left_distance := 0
  right_distance := 0
  com_x := 0
  com_y := 0
  wait_mS := clkfreq/1000 '1 mS   
  ResetGrid

  'bytemove(@stringbuffer,@@SYSTEM_MC,strlen(@@SYSTEM_MC))  

  'Set LED Pins as outputs if they should be.  We don't know if they are contiguous or not.
  DIRA[Startup_LED]~~
  DIRA[Run_LED]~~
  DIRA[Armed_LED]~~
  DIRA[Error_LED]~~
  OUTA[Startup_LED] := TRUE
  OUTA[Run_LED] := FALSE
  OUTA[Armed_LED] := FALSE
  OUTA[Error_LED] := FALSE

  'Wait a couple seconds before doing anything
  
  cogsused := 0
  slow_loop_count := medium_loop_count := fast_loop_count := 0
  i := 0      
  'Set GPIO Pins as Inputs/Outputas as needed.
  DIRA[Arm_Pin]~

   'Initialize all Ports
  uart.init                    

  uart.AddPort(debug_port,usbrx,usbtx,uart#PINNOTUSED,uart#PINNOTUSED,uart#DEFAULTTHRESHOLD,uart#NOMODE,uart#BAUD9600)
  uart.AddPort(com_port,comrx,comtx,uart#PINNOTUSED,uart#PINNOTUSED,uart#DEFAULTTHRESHOLD,uart#NOMODE,uart#BAUD9600)
  uart.tx(com_port,12)
  waitcnt(clkfreq*5 + cnt)        
  'uart.AddPort(debug_port,comrx,comtx,-1,-1,0,-%000000,uart#BAUD115200)
                         
  if (temp1 := uart.Start) 
      cogsused += 1 'Should be 1
      uart.rxflush(debug_port)
      uart.rxflush(debug_port)  

  if (temp1 := pwmout.start) 'servo.start
    cogsused += 1 'Should be 2
  else
    uart.str(debug_port,string("pwmout not started"))
    uart.dec(debug_port,temp1)
  
  if (temp1 := timer.start)
    timer.run
    cogsused += 1 'Should be 3
  else
    uart.str(debug_port,string("timer not started"))
    uart.dec(debug_port,temp1)

  {if (temp1 := ledpwm.start)
    cogsused += 1 'Should be 4
  else
    uart.str(debug_port,string("ledpwm not started"))
    uart.dec(debug_port,temp1)
    }

  'pwmin.Start(FrontMotorInPin)
  
  'Start sensors

  if (temp1 := adc.start(ADCuartPin, ADCclkPin, ADCcsPin, ADCmode))
    cogsused += 1 'Should be 5
  else
    uart.str(debug_port,string("adc not started"))
    uart.dec(debug_port,temp1)
    
  if (temp1 := sdcard.mount(SD_DO))

  else
    uart.str(debug_port,string("sdcard card not mounted"))
    uart.dec(debug_port,temp1)

  math.Start_Driver   
  uart.str(debug_port,string("Cog's Used:"))
  uart.dec(debug_port,cogsused)
  uart.str(debug_port,string(CR,LF))
   
  if cogsused == 4 ' Check Initializing for Errors

    'Transmit MAVLink State
   OUTA[Startup_LED] := FALSE
    runprogram
  else
    
    repeat
      waitcnt(clkfreq/4 + cnt)
      !outa[Error_LED] 'Error on startup, couldn't initialize 
{OUTA[Startup_LED] := TRUE
  OUTA[ManualMode_LED] := FALSE
  OUTA[TestMode_LED] := FALSE
  OUTA[Error_LED] := FALSE
}
PUB runprogram

  
  repeat
    waitcnt(clkfreq/100 + cnt)
    !outa[Run_LED]
    UpdateGrid
    'SetGoalOnGrid(-3,3)
    FindGridCoM
    PrintGrid
    'UpdateSetPoints
    'left_distance := ping.Inches(PING_LEFT)
    'right_distance := ping.Inches(PING_RIGHT)
    'uart.str(debug_port,string("LEFT: "))   
    'uart.dec(debug_port,left_distance)
    
    'uart.str(debug_port,string(" RIGHT: "))
    'uart.dec(debug_port,right_distance)    
    'uart.str(debug_port,string(CR,LF))
Pub UpdateSetPoints| x,y,tempstr
  'target_theta
  x := math.Qval(target_x)
  y := math.Qval(target_y)
  tempstr := math.QvalToStr(math.Deg_ATAN2(x,y))
  target_theta := util. strntodec(tempstr,0) - 90
  uart.str(debug_port,string("Target Theta: "))
  uart.dec(debug_port,target_theta)
  uart.str(debug_port,string(CR,LF))
Pub SetGoalOnGrid(x,y) | i,j,sum  'Tries to search for a Free location at or near desired grid value    
  sum := 0
  x := x + 3
  y := y - 3
  repeat i from 0 to (GRIDSIZE*GRIDSIZE)-1
    sum := sum + occupancy_grid[i]
  occupancy_grid[x+y*GRIDSIZE] := -sum/2
Pub FindGridCoM| i,j,Mx,My, value,mass
  mass := 0
  Mx := 0
  My := 0
  repeat i from -3 to 3
    repeat j from 3 to -3
        value := GetGridValue(i,j)
        Mx := Mx + value * i
        My := My + value * j
        mass := mass + value
        {
        uart.str(debug_port,string("i:"))
        uart.dec(debug_port,i)
        uart.str(debug_port,string("j:"))
        uart.dec(debug_port,j)
        uart.str(debug_port,string("Mx:"))
        uart.dec(debug_port,Mx)
        uart.str(debug_port,string("My:"))
        uart.dec(debug_port,My)
        uart.str(debug_port,string(CR,LF))  }
                                             
  Mx := Mx * (GRIDSIZE-1)/(mass)
  My := My * (GRIDSIZE-1)/(mass)
  com_x := Mx
  com_y := My
  target_x := -com_x
  target_y := -com_y
  target_x := -3 #> target_x <# 3
  target_y := -3 #> target_y <# 3
 { 
  uart.str(debug_port,string("Tx: "))
  uart.dec(debug_port,target_x)
  uart.str(debug_port,string(" Ty: "))
  uart.dec(debug_port,target_y)
  uart.str(debug_port,string(CR,LF)) 
  }    
Pub UpdateGrid|rowtomark,coltomark,i,j
  ResetGrid
  front_distance := ping.Inches(PING_FRONT) 
  right_distance := ping.Inches(PING_RIGHT)
  left_distance := ping.Inches(PING_LEFT)
  'uart.str(debug_port,string(" FRONT: "))
  'uart.dec(debug_port,front_distance)
  'uart.str(debug_port,string(CR,LF))
  if front_distance > BEYONDFAR
    rowtomark := -1
  elseif front_distance > FAR
    rowtomark := 0
  elseif front_distance > MID
    rowtomark := 1
  elseif front_distance < MID
    rowtomark := 2
  if rowtomark => 2
    repeat i from 16 to 18
      occupancy_grid[i] := 1
  if rowtomark => 1
    repeat i from 8 to 12
      occupancy_grid[i] := 1
  if rowtomark => 0
    repeat i from 0 to 6
      occupancy_grid[i] := 1
  
  if right_distance > BEYONDFAR
    coltomark := 10
  elseif right_distance > FAR
    coltomark := 3
  elseif right_distance > MID
    coltomark := 2
  elseif right_distance < MID
    coltomark := 1
  if coltomark =< 1
    repeat i from 0 to 2
      occupancy_grid[18+(i*GRIDSIZE)] := 1
  if coltomark =< 2
    repeat i from 0 to 4
      occupancy_grid[12+(i*GRIDSIZE)] := 1
  if coltomark =< 3
    repeat i from 0 to 6
      occupancy_grid[6+(i*GRIDSIZE)] := 1
  

  if left_distance > BEYONDFAR
     coltomark := 10
  elseif left_distance > FAR
    coltomark := 3
  elseif left_distance > MID
    coltomark := 2
  elseif left_distance < MID
    coltomark := 1
  if coltomark =< 1
    repeat i from 0 to 2
      occupancy_grid[16+(i*GRIDSIZE)] := 1
  if coltomark =< 2
    repeat i from 0 to 4
      occupancy_grid[8+(i*GRIDSIZE)] := 1
  if coltomark =< 3
    repeat i from 0 to 6
      occupancy_grid[0+(i*GRIDSIZE)] := 1     
Pub GetGridValue(x,y)  
  x := x + 3
  y := 3 - y
  return occupancy_grid[x+y*GRIDSIZE]         

Pub PrintGrid|i,j
  uart.str(debug_port,string("    FRONT",CR,LF))
  uart.str(debug_port,string("--------------",CR,LF))
  repeat i from 0 to GRIDSIZE - 1
    repeat j from 0 to GRIDSIZE - 1
      uart.dec(debug_port,occupancy_grid[j+i*GRIDSIZE])
      uart.tx(debug_port,SPACE)
    uart.str(debug_port,string(CR,LF))
  uart.str(debug_port,string("--------------",CR,LF))
  uart.str(debug_port,string("   BACK"))
  uart.str(debug_port,string(CR,LF))
  uart.str(debug_port,string(CR,LF))   
  uart.str(debug_port,string(CR,LF))
Pub ResetGrid| i,j
  repeat i from 0 to GRIDSIZE-1
    repeat j from 0 to GRIDSIZE - 1
      occupancy_grid[j+i*GRIDSIZE] := 0
  occupancy_grid[((GRIDSIZE*GRIDSIZE-1)/2)] := 1
  repeat i from 30 to 32
    occupancy_grid[i] := 1
  repeat i from 36 to 40
    occupancy_grid[i] := 1
  repeat i from 42 to 48
    occupancy_grid[i] := 1
  