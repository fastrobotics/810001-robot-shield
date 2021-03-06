{{               
********************************************************
* Robot Shield Demo Rev A                              *
* Author: David Gitz                                   *
* Copyright (c) 2014 David Gitz/FAST Robotics          *     
********************************************************

TODO

   
{{
TARGET:
  - Robot Controller (FR# 810001)
PURPOSE:

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
  DPG 27-JULY-2014. Created Program from 646000.  Designed FAST Com Protocol and implemented several messages.  Tested movements with 1 Servo.
  DPG 28-JULY-2014. Coded for heartbeats, com dropout.

 
  
}}
CON

' Timing             
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000 
  
' ASCII Constants
  CR = $0D
  LF = $0A
  SPACE = 32
  PERIOD = 46
  COMMA =  44
  TAB = 9

 'Loop Rates
  FAST_LOOP = 1 '1000 Hz
  MEDIUM_LOOP = 10 '100 Hz
  SLOW_LOOP = 100 '10 Hz
  VERYSLOW_LOOP = 900


  PRIORITY_HIGH = 0
  PRIORITY_MEDIUM = 1
  PRIORITY_LOW = 2
  PRIORITY_VERYLOW = 3


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
  STEER_MIN_VALUE = 1850
  STEER_MAX_VALUE = 1150
  STEER_NEUTRAL_VALUE = 1500

  'FAST Protocol Definitions
  SD = $24
  ED = $2A
  'Message/Sub-Message Type Definitions
  MT_ERROR = $01
  SMT_NOERROR = $01

  MT_ACTUATOR = $02
  SMT_GENERAL = $01

  MT_ARMED = $03
  'SMT_GENERAL
  V_ARMED = $01
  V_DISARMED = $02

  MT_HEARTBEAT = $04
  'SMT_GENERAL


  'Value Type Definitions
  VT_NODATA = $FF
  VT_1INT = $01
  VT_2INT = $02
   
  ' User Pin Definitions
  Arm_Pin = GPIO1
  Left_Pot = AnalogSense1
  Right_Pot = AnalogSense2
  Startup_LED = LED1
  RunCLIMode_LED = LED2
  Armed_LED = LED3
  Error_LED = LED4

  ' CLI MODE CONSTANTS
  DEBUG_MENU = 1
  DEBUG_SERVO = 1
  DEBUG_UART = 2
  DEBUG_ANALOG = 3
  DEBUG_PWM = 4
  DEBUG_SD = 5
  DEBUG_GPIO = 6
  DEBUG_LED = 7
  DEBUG_ALLIO = 8
  DEBUG_ALL = 9

  CALIB_MENU = 2

  GPIO_INPUT = 1
  GPIO_OUTPUT = 2

    'Remote Control Definitions
  GUI_ACTUATOR_MIN = 1
  GUI_ACTUATOR_MAX = 255
  GUI_ACTUATOR_NEUTRAL = 128
  ThrottleCh = GPIO2
  SteerCh = SERVO1
  



OBJ
  uart:         "pcFullDuplexSerial4FC"
  pwmout:       "PWM_32_v4"
  util:         "Util"
  math:         "DynamicMathLib"
  fstring:      "FloatString"
  adc:          "MCP3208"
  timer:        "Timer"
  str:          "STRINGS2"
  sdcard:           "fsrw"
  'uart_com:     "FullDuplexSerial"
  'uart_debug:   "FullDuplexSerial"

VAR
  'Program Variables
  byte cogsused

  'Timing Variables
  long wait_mS
  long elapsedtime
  long veryslow_loop_count
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
  byte message_type
  byte packet_length
  byte submessage_type
  byte value_type
  byte heartbeatout_counter
  byte heartbeatin_counter
  byte heartbeatin_skipped
  byte lastbeat
  byte comdropout_trigger
   
  

  'Motor Variables
  byte Armed
  long MotorOutPWM[4] 'Front,Left,Back,Right
  long MotorAdjustPWM[4] 'Front,Left,Back,Right
  byte steer_cmd
  byte throttle_cmd

  'SD Card Variables
  byte tbuf[20]
  byte bigbuf[256]

PUB init | i,sum, tempstr, temp1,fileerror
  
  steer_cmd := GUI_ACTUATOR_NEUTRAL
  throttle_cmd := GUI_ACTUATOR_NEUTRAL
  heartbeatout_counter := 1
  heartbeatin_skipped := 0
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


   'Initialize all Ports
  uart.init                    
  {uart_com.start(comrx, comtx, %1000, 9600)
  uart_debug.start(usbrx,usbtx,%0000,9600)
  repeat
     temp1 := uart_com.rx
     uart_com.str(string("HELLO"))
     uart_com.tx(temp1)
     uart_com.str(string(CR,LF))
     waitcnt(clkfreq/100 + cnt) }
  uart.AddPort(debug_port,usbrx,usbtx,uart#PINNOTUSED,uart#PINNOTUSED,uart#DEFAULTTHRESHOLD,uart#NOMODE,uart#BAUD9600)
  uart.AddPort(com_port,comrx,comtx,uart#PINNOTUSED,uart#PINNOTUSED,uart#DEFAULTTHRESHOLD,%001000,uart#BAUD9600) 
  'uart.AddPort(debug_port,comrx,comtx,-1,-1,0,-%000000,uart#BAUD115200)

                         
  if (temp1 := uart.Start) 
      cogsused += 1 'Should be 1
      uart.rxflush(debug_port)
      uart.rxflush(debug_port)
      uart.rxflush(com_port)
      uart.rxflush(com_port) 

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
    
  uart.str(debug_port,string("Cog's Used:"))
  uart.dec(debug_port,cogsused)
  uart.str(debug_port,string(CR,LF))
 { repeat
    'uart.str(com_port,string("HELLO, WORLD",CR,LF))
    
    'uart.str(debug_port,string("HELLO,WORLD",CR,LF))
    temp1 := uart.rx(com_port)
    uart.tx(com_port,temp1)
    waitcnt(clkfreq/100 + cnt) }
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
  fast_loop_count := medium_loop_count := slow_loop_count := veryslow_loop_count := 0
  lasttime := 0
  temp1 := 0
  armedstart := FALSE
  armedtimer := 0
  comdropout_trigger := 0

  bootmode := 0

  repeat
    waitcnt(1*wait_mS + cnt) ' Wait 100 mS
    ontime++
    if ontime > 1000
      ontime := 1
      fast_loop_count := medium_loop_count := slow_loop_count := veryslow_loop_count := 0
    if (ontime - fast_loop_count) > FAST_LOOP
      fast_loop_count := ontime 
      prioritylevel := PRIORITY_HIGH        
     
    elseif (ontime - medium_loop_count) > MEDIUM_LOOP
      medium_loop_count := ontime
      prioritylevel := PRIORITY_MEDIUM      
     
    elseif (ontime - slow_loop_count) > SLOW_LOOP
      slow_loop_count := ontime
      prioritylevel := PRIORITY_LOW
    elseif (ontime - veryslow_loop_count) > VERYSLOW_LOOP
      veryslow_loop_count := ontime
      prioritylevel := PRIORITY_VERYLOW
    else
      prioritylevel := -1                 

   
    case prioritylevel
           
      PRIORITY_HIGH: 'Read Mode (Arm/Disarm) Commands
    
        'Armed := INA[Arm_Pin]
        if INA[Arm_Pin] == False
          Armed := False 
        OUTA[Armed_LED] := Armed
        if Armed == False
          throttle_cmd := GUI_ACTUATOR_NEUTRAL
          steer_cmd := GUI_ACTUATOR_NEUTRAL
        rxbyte := uart.rx(com_port)
        
        if rxbyte ==  SD
          packet_length := uart.rx(com_port)
          'uart.dec(com_port,packet_length)
          'uart.tx(com_port,CR)
          'uart.tx(com_port,LF)
           'uart.tx(debug_port,rxbyte) 
          repeat i from 1 to packet_length
            
            comrxbuffer[i] := uart.rx(com_port)
            'uart.tx(debug_port,comrxbuffer[i])
          
          rxbyte := uart.rx(com_port)
          'uart.tx(debug_port,rxbyte)
          'uart.tx(debug_port,CR)
          'uart.tx(debug_port,LF)
          if rxbyte == ED
            process_fast_message
          
          else
            uart.tx(debug_port,string("nope",CR,LF))
        IF Armed == 0
          
      PRIORITY_MEDIUM: 'Read Sensors, Move Actuators
        'uart.dec(com_port,MotorOutPWM[FrontMotorCh])
        '!OUTA[6]
        
        value1 :=  map_value(throttle_cmd,GUI_ACTUATOR_MIN,GUI_ACTUATOR_MAX,PWM_MIN_VALUE,PWM_MAX_VALUE)
        value2 :=  map_value(steer_cmd,GUI_ACTUATOR_MIN,GUI_ACTUATOR_MAX,STEER_MIN_VALUE,STEER_MAX_VALUE)
        uart.dec(debug_port,value1)
        uart.str(debug_port,string(","))
        uart.dec(debug_port,value2)
        uart.str(debug_port,string(CR,LF))  
        pwmout.Servo(ThrottleCh,value1)
        pwmout.Servo(SteerCh,value2)
        heartbeatout_counter++
        if heartbeatout_counter == 256
          heartbeatout_counter := 1                                                      
        uart.str(com_port,string(SD,$04,MT_HEARTBEAT,SMT_GENERAL,VT_1INT))
        uart.tx(com_port,heartbeatout_counter)
        uart.tx(com_port,ED)
           

      PRIORITY_LOW:  'Reply to PC
  
        !OUTA[RunCLIMode_LED]
        heartbeatin_skipped := 0 
        comdropout_trigger++
      PRIORITY_VERYLOW:
        if comdropout_trigger > 10
          Armed := False
          'uart.str(com_port,string("COM DROPOUT",CR,LF))
        else
          'uart.str(com_port,string("COM OK",CR,LF))
          
         
        'Transmit Measured PWM Input Values
        'uart.txflush(com_port)
      'Data Logging
      OTHER:
        'uart.dec(com_port,0)
PUB process_fast_message| i
'Entering here correctly.
'comrxbuffer[1]: Message Type
'comrxbuffer[2]: Sub-Message Type
'comrxbuffer[3]: Value Type
'comrxbuffer[4..packet_length]: Values
    
    if comrxbuffer[1] == MT_ERROR
    elseif comrxbuffer[1] == MT_ACTUATOR
      if comrxbuffer[2] == SMT_GENERAL
        if comrxbuffer[3] == VT_2INT
          if Armed
             
            steer_cmd := comrxbuffer[4]
            throttle_cmd := comrxbuffer[5]
    elseif comrxbuffer[1] == MT_ARMED
                                     
      if comrxbuffer[2] == SMT_GENERAL
        if comrxbuffer[3] == VT_1INT
          if comrxbuffer[4] == V_ARMED
            uart.str(debug_port,string("got here"))
            Armed := True AND INA[Arm_Pin]
          elseif comrxbuffer[4] == V_DISARMED

            Armed := False
    elseif comrxbuffer[1] == MT_HEARTBEAT
      if comrxbuffer[2] == SMT_GENERAL
        if comrxbuffer[3] == VT_1INT
           comdropout_trigger := 0
           lastbeat := heartbeatin_counter
           heartbeatin_counter := comrxbuffer[4]
           if heartbeatin_counter == 0
              heartbeatin_skipped := heartbeatin_skipped + heartbeatin_counter - lastbeat - 1 + 256
           else
             heartbeatin_skipped := heartbeatin_skipped + heartbeatin_counter - lastbeat - 1
            
          
  'uart.tx(com_port,CR)
  'uart.tx(com_port,LF)
PUB map_value(x,x_min,x_max,y_min,y_max)
  return ((x-x_min) * (y_max-y_min)/(x_max-x_min)) + y_min
  