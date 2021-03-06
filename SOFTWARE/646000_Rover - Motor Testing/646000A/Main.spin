                                                                                                {{               
********************************************************
* main                                                 *
* Author: David Gitz                                   *
* Copyright (c) 2014 David Gitz/FAST Robotics          *     
********************************************************

TODO
  - CLI
  - Analog Input - DONE
  - PWM Output - DONE
  - SETUP Info
  - Indicator Lights - DONE
   
{{
TARGET:
  - Motion Controller (FR# 810001)
PURPOSE:
  - Test FAST Rover (FR# 810000) Drive Motors w/ Analog Potentiometers or CLI
}}
{{
SETUP:
}}
{{
INDICATOR LIGHTS
LED1: On During Startup, Off otherwise
LED2: Blining if Running, On in CLI Mode, Off if Not Running
LED3: On if Armed, Off if Disarmed 
LED4: On if Error, Off otherwise.
}}
{{
LOG:
  DPG 4-JUL-2014.  Created Program.
  DPG 12-JUL-2014. Tested Pogram on Test Motor Setup w/ 1 Motor and Wheel, works.
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
    
  ' Pin Names
  PINNOTUSED = -1                    

  ' UART Stuff
  usbtx = 30  'USB TX Line
  usbrx = 31  'USB RX Line

  pc_port = 0


  'Loop Rates
  FAST_LOOP = 1 '100 Hz, 10 mS
  MEDIUM_LOOP = 10 '10 Hz, 50 mS
  SLOW_LOOP = 100 '1 Hz, 200 mS

  PRIORITY_HIGH = 0
  PRIORITY_MEDIUM = 1
  PRIORITY_LOW = 2

' Led's

  Startup_LED = 17
  RunCLIMode_LED = 18
  Armed_LED = 19
  Error_LED = 20

' Motor Out Pin: Set to -1 if not used
  FLMotorPin = 16
  FRMotorPin = 5
  BLMotorPin = -1
  BRMotorPin = -1

  PWM_MIN_VALUE = 1000
  PWM_MAX_VALUE = 2000
  PWM_NEUTRAL_VALUE = 1500

  FLMotorCh = 0
  FRMotorCh = 1
  BLMotorCh = 2
  BRMotorCh = 3 

  'ADC Pins/Misc
  ADCuartPin = 21
  ADCclkPin = 22
  ADCcsPin = 23
  ADCmode = $00FF

  'Analog Sensors
  AnalogSense1 = 0
  AnalogSense2 = 1
  AnalogSense3 = 2
  AnalogSense4 = 3
  AnalogSense5 = 4
  AnalogSense6 = 5
  AnalogSense7 = 6
  AnalogSense8 = 7

  Left_Pot = AnalogSense1
  Right_Pot = AnalogSense2

  'SONIC_THRESHOLD = 500   
  ADC_VOLTAGE_CONVERSION = 18

  ADC_LOWER_THRESHOLD = 100  'Threshold for converting Analog Input to Boolean states.  Below this is FALSE.
  ADC_UPPER_THRESHOLD = 3900   'Threshold for converting Analog Input to Boolean states.  Above this is TRUE.
  ADC_MIN_VALUE = 0
  ADC_MAX_VALUE = 4096
  'CurrentSense = 1
  'VoltageSense = 0

 'GPIO Pin Definitions
  GPIO1 = 6
  GPIO2 = 5
  GPIO3 = 4
  GPIO4 = 3
  GPIO5 = 2

  Arm_Pin = GPIO1

OBJ
  uart:         "pcFullDuplexSerial4FC"
  pwmout:       "PWM_32_v4"
  util:         "Util"
  math:         "DynamicMathLib"
  fstring:      "FloatString"
  adc:          "MCP3208"
  timer:        "Timer"
  str:          "STRINGS2"

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

  

  'Motor Variables
  byte Armed
  long MotorOutPWM[4] 'Front,Left,Back,Right
  long MotorAdjustPWM[4] 'Front,Left,Back,Right

PUB init | i,sum, tempstr, temp1,fileerror
  
  
  wait_mS := clkfreq/1000 '1 mS   
  

  'bytemove(@stringbuffer,@@SYSTEM_MC,strlen(@@SYSTEM_MC))  

  'Set LED Pins as outputs if they should be.  We don't know if they are contiguous or not.
  DIRA[Startup_LED]~~
  DIRA[RunCLIMode_LED]~~
  DIRA[Armed_LED]~~
  DIRA[Error_LED]~~
  OUTA[Startup_LED] := TRUE
  OUTA[RunCLIMode_LED] := FALSE
  OUTA[Armed_LED] := FALSE
  OUTA[Error_LED] := FALSE

  'Wait a couple seconds before doing anything
  waitcnt(clkfreq*5 + cnt)
  cogsused := 0
  slow_loop_count := medium_loop_count := fast_loop_count := 0
  i := 0      
  'Set GPIO Pins as Inputs/Outputas as needed.
  DIRA[Arm_Pin]~

  'Set Motor Output Pins as Outputs
  if FLMotorPin <> -1
    dira[FLMotorPin]~~
  if GPIO2 <> -1
    dira[GPIO2]~~
  if BLMotorPin <> -1
    dira[BLMotorPin]~~
  if BRMotorPin <> -1
    dira[BRMotorPin]~~

   'Initialize all Ports
  uart.init                    

  uart.AddPort(pc_port,usbrx,usbtx,uart#PINNOTUSED,uart#PINNOTUSED,uart#DEFAULTTHRESHOLD,uart#NOMODE,uart#BAUD9600)
  'uart.AddPort(pc_port, usbrx,usbtx, -1,-1, 0, %000000, uart#BAUD115200)
  'uart.AddPort(pc_port,comrx,comtx,-1,-1,0,-%000000,uart#BAUD115200)
                         
  if (temp1 := uart.Start) 
      cogsused += 1 'Should be 1
      uart.rxflush(pc_port)
      uart.rxflush(pc_port)  

  if (temp1 := pwmout.start) 'servo.start
    cogsused += 1 'Should be 2
  else
    uart.str(pc_port,string("pwmout not started"))
    uart.dec(pc_port,temp1)
  
  if (temp1 := timer.start)
    timer.run
    cogsused += 1 'Should be 3
  else
    uart.str(pc_port,string("timer not started"))
    uart.dec(pc_port,temp1)

  {if (temp1 := ledpwm.start)
    cogsused += 1 'Should be 4
  else
    uart.str(pc_port,string("ledpwm not started"))
    uart.dec(pc_port,temp1)
    }

  'pwmin.Start(FrontMotorInPin)
  
  'Start sensors

  if (temp1 := adc.start(ADCuartPin, ADCclkPin, ADCcsPin, ADCmode))
    cogsused += 1 'Should be 5
  else
    uart.str(pc_port,string("adc not started"))
    uart.dec(pc_port,temp1)
    

  uart.str(pc_port,string("Cog's Used:"))
  uart.dec(pc_port,cogsused)
  uart.str(pc_port,string(CR,LF))

  if cogsused == 4 ' Check Initializing for Errors

    'Transmit MAVLink State
   OUTA[Startup_LED] := FALSE
   mainloop
  else
    
    repeat
      waitcnt(clkfreq/4 + cnt)
      outa[Error_LED] := TRUE 'Error on startup, couldn't initialize 
{OUTA[Startup_LED] := TRUE
  OUTA[ManualMode_LED] := FALSE
  OUTA[TestMode_LED] := FALSE
  OUTA[Error_LED] := FALSE
}      
PUB mainloop | i, j, value1, value2, value3,bootmode,ledmode,ledpin , tempstrA,tempstrB,tempstrC,storagecount,temp1, lasttime
  ontime := 0
  prioritylevel := -1
  fast_loop_count := medium_loop_count := slow_loop_count := 0
  lasttime := 0
  temp1 := 0
  armedstart := FALSE
  armedtimer := 0
  'bytefill(@sdtextbuffer,0,500)
  'bytemove(@sdtextbuffer,0,0)

  {repeat i from 0 to 7   ' Set all Servo PWM's to Neutral
    apm_servocmd[i] := 1500
    servo_min[i] := 1000
    servo_center[i] := 1500
    servo_max[i] := 2000
   } 

  bootmode := 0

  repeat' until strcomp(@rxbuffer,string("done"))
    waitcnt(1*wait_mS + cnt) ' Wait 100 mS
    ontime++
    if ontime > 1000
      ontime := 1
      fast_loop_count := medium_loop_count := slow_loop_count := 0
    if (ontime - fast_loop_count) > FAST_LOOP
      fast_loop_count := ontime 
      prioritylevel := PRIORITY_HIGH        
     
    elseif (ontime - medium_loop_count) > MEDIUM_LOOP
      medium_loop_count := ontime
      prioritylevel := PRIORITY_MEDIUM      
     
    elseif (ontime - slow_loop_count) > SLOW_LOOP
      slow_loop_count := ontime
      prioritylevel := PRIORITY_LOW 
    else
      prioritylevel := -1                 

   
    case prioritylevel
           
      PRIORITY_HIGH: 'Read Mode (Arm/Disarm) Commands
    
        Armed := INA[Arm_Pin]
        OUTA[Armed_LED] := Armed
        IF Armed == 0
        
          pwmout.Servo(FLMotorPin,PWM_NEUTRAL_VALUE)
          pwmout.Servo(GPIO2,PWM_NEUTRAL_VALUE)
          pwmout.Servo(BLMotorPin,PWM_NEUTRAL_VALUE)
          pwmout.Servo(BRMotorPin,PWM_NEUTRAL_VALUE)
      PRIORITY_MEDIUM: 'Read Sensors, Move Actuators
        MotorOutPWM[FLMotorCh] := map_value(adc.in(Right_Pot),ADC_MIN_VALUE,ADC_MAX_VALUE,PWM_MIN_VALUE,PWM_MAX_VALUE)
        MotorOutPWM[FRMotorCh] := map_value(adc.in(Left_Pot),ADC_MIN_VALUE,ADC_MAX_VALUE,PWM_MIN_VALUE,PWM_MAX_VALUE)
        MotorOutPWM[BLMotorCh] := MotorOutPWM[FLMotorCh]
        MotorOutPWM[BRMotorCh] := MotorOutPWM[FRMotorCh]                                                                          
        'uart.dec(pc_port,MotorOutPWM[FrontMotorCh])
        '!OUTA[6]
        uart.str(pc_port,string("L:"))
        uart.dec(pc_port,MotorOutPWM[FLMotorCh])
        uart.str(pc_port,string(",R:"))
        uart.dec(pc_port,MotorOutPWM[FRMotorCh])
        uart.str(pc_port,string(CR,LF))
        pwmout.Servo(FLMotorPin,MotorOutPWM[FLMotorCh])
        pwmout.Servo(GPIO2,MotorOutPWM[FRMotorCh])
        pwmout.Servo(BLMotorPin,MotorOutPWM[BLMotorCh])
        pwmout.Servo(BRMotorPin,MotorOutPWM[BRMotorCh])
      

      PRIORITY_LOW:  'Reply to PC
  
        !OUTA[RunCLIMode_LED]
        'Transmit Measured PWM Input Values
        'uart.txflush(pc_port)
      'Data Logging
      OTHER:
        'uart.dec(pc_port,0)

PUB map_value(x,x_min,x_max,y_min,y_max)
  return ((x-x_min) * (y_max-y_min)/(x_max-x_min)) + y_min