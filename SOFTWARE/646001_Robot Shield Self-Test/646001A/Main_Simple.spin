{{               
********************************************************
* Robot Controller Self-Test                           *
* Author: David Gitz                                   *
* Copyright (c) 2014 David Gitz/FAST Robotics          *     
********************************************************

TODO
  - Analog Input - DONE
  - LED's - TEST
  - PWM Output - TEST
  - CLI - TEST
  - SD Card - DONE
  - GPIO Pins - DONE
  - All Tests
   
{{
TARGET:
  - Robot Controller (FR# 810001)
PURPOSE:
  - Perform Self-Test and CLI Mode Tests
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
  DPG 17-JUL-2014.  Created Program.  Tested operation for SD Card.  Started working on CLI.  
 
  
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
  FLMotorCh = 0
  FRMotorCh = 1
  BLMotorCh = 2
  BRMotorCh = 3

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
  Left_Pot = AnalogSense1
  Right_Pot = AnalogSense2
  Startup_LED = LED1
  RunCLIMode_LED = LED2
  Armed_LED = LED3
  Error_LED = LED4
  FLMotorPin = SERVO1
  FRMotorPin = SERVO2
  BLMotorPin = SERVO3
  BRMotorPin = SERVO4

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
  CALIB_STEER = 1

  GPIO_INPUT = 1
  GPIO_OUTPUT = 2


OBJ
  uart:         "FullDuplexSerial"
  pwmout:       "PWM_32_v4"
  util:         "Util"
  math:         "DynamicMathLib"
  fstring:      "FloatString"
  adc:          "MCP3208"
  timer:        "Timer"
  str:          "STRINGS2"
  sdcard:           "fsrw"

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
  long MotorOutPWM[4] 'Front,Left,Back,Right
  long MotorAdjustPWM[4] 'Front,Left,Back,Right

  'SD Card Variables
  byte tbuf[20]
  byte bigbuf[256]

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
  if FRMotorPin <> -1
    dira[FRMotorPin]~~
  if BLMotorPin <> -1
    dira[BLMotorPin]~~
  if BRMotorPin <> -1
    dira[BRMotorPin]~~

   'Initialize all Ports
  uart.start(usbrx,usbtx,0,9600)

 ' repeat
  '  waitcnt(clkfreq/10 + cnt)
 '   !outa[Error_LED]
 '   uart.str(string("HELLO WORLD",CR,LF))
  'uart.AddPort(debug_port,comrx,comtx,-1,-1,0,-%000000,uart#BAUD115200)
                         

  if (temp1 := pwmout.start) 'servo.start
    cogsused += 1 'Should be 2
  else
    uart.str(string("pwmout not started"))
    uart.dec(temp1)
  
  if (temp1 := timer.start)
    timer.run
    cogsused += 1 'Should be 3
  else
    uart.str(string("timer not started"))
    uart.dec(temp1)

  {if (temp1 := ledpwm.start)
    cogsused += 1 'Should be 4
  else
    uart.str(string("ledpwm not started"))
    uart.dec(temp1)
    }

  'pwmin.Start(FrontMotorInPin)
  
  'Start sensors

  if (temp1 := adc.start(ADCuartPin, ADCclkPin, ADCcsPin, ADCmode))
    cogsused += 1 'Should be 5
  else
    uart.str(string("adc not started"))
    uart.dec(temp1)
    
  if (temp1 := sdcard.mount(SD_DO))

  else
    uart.str(string("sdcard not mounted"))
    uart.dec(temp1)
    
  uart.str(string("Cog's Used:"))
  uart.dec(cogsused)
  uart.str(string(CR,LF))
   
  repeat
    
       climode


pub climode| i, exit,choice
'' DPG 1-JAN-2013
'' Added Command Line Interface Mode
  exit := 0
  outa[RunCLIMode_LED] := 1
  repeat
    exit := 0
    repeat i from 0 to 3
      uart.str(@@mainAddr[i])
      waitcnt(clkfreq/250 + cnt)
    choice := -1
    choice := getpcrxdec
    uart.dec(choice)
    if choice == DEBUG_MENU 'Debug/Testing Menu
      repeat until exit == 1
        exit := 0
        repeat i from 0 to 9
           uart.str(@@debugAddr[i])
          waitcnt(clkfreq/250 + cnt)
        choice := -1
        choice := getpcrxdec
        if choice == DEBUG_SERVO
          debugmode(DEBUG_SERVO)
        elseif choice == DEBUG_UART
          debugmode(DEBUG_UART)
        elseif choice == DEBUG_ANALOG

          debugmode(DEBUG_ANALOG)
        elseif choice == DEBUG_PWM
          debugmode(DEBUG_PWM)
        elseif choice == DEBUG_SD
          debugmode(DEBUG_SD)
        elseif choice == DEBUG_GPIO
          repeat i from 0 to 2
            uart.str(@@gpioAddr[i])
            waitcnt(clkfreq/250 + cnt)
          choice := -1
          choice := getpcrxdec
          if choice == GPIO_INPUT
            debugmode_gpio(GPIO_INPUT)
          elseif choice == GPIO_OUTPUT
            debugmode_gpio(GPIO_OUTPUT)
          else
            exit := 1
        elseif choice == DEBUG_LED
          debugmode(DEBUG_LED)
        elseif choice == DEBUG_ALLIO
          debugmode(DEBUG_ALLIO)
        elseif choice == 0
          exit := 1
        else
          exit := 1          
    elseif choice == CALIB_MENU 'Calibration Menu
      repeat until exit == 1
        exit := 0
        repeat i from 0 to 2
           uart.str(@@calibAddr[i])
          waitcnt(clkfreq/250 + cnt)
        choice := -1
        choice := getpcrxdec
        if choice == 0
          exit := 1
        elseif choice == CALIB_STEER
          calib_mode(CALIB_STEER)
        else
          exit := 1

pri getpcrxdec | num
  num := uart.rx - 48
  return num
pri calib_mode(option)|state
  state := 0
  waitcnt(clkfreq* 2 + cnt)
  if option == CALIB_STEER
    repeat 1000
      if state == 0
        turn_forwards
      elseif state == 1
        turn_left
      elseif state == 2
        turn_forwards
      elseif state == 3
        turn_right
      state := state + 1
      if state ==4
        state := 0
        uart.str(string(CR,LF,CR,LF))
pri turn_forwards
  uart.str(string("Turning Forwards",CR,LF))
  pwmout.Servo(SERVO1,PWM_NEUTRAL_VALUE)
  waitcnt(clkfreq/2 + cnt)
pri turn_left
  uart.str(string("Turning Left",CR,LF))
  pwmout.Servo(SERVO1,PWM_MIN_VALUE)
  waitcnt(clkfreq/2 + cnt)

pri turn_right
  uart.str(string("Turning Right",CR,LF))
  pwmout.Servo(SERVO1,PWM_MAX_VALUE)
  waitcnt(clkfreq/2 + cnt)  
pri debugmode_gpio(debug_gpiooption) | exit,i,j
  waitcnt(clkfreq*2 + cnt)
  if debug_gpiooption == GPIO_INPUT
    exit := 0
    i := 0
    DIRA[US1..US4]~
    DIRA[GPIO1..GPIO5]~
    repeat until i == 100000
      j := 0
      repeat j from 0 to 4
        uart.str(string("G "))
        uart.dec(j+1)
        uart.str(string(SPACE))
        uart.bin(INA[GPIO1-j],1) 'Since GPIO1 is higher than GPIO5.
        uart.tx(TAB)
      repeat j from 0 to 3
        uart.str(string("U "))
        uart.dec(j+1)
        uart.str(string(SPACE))
        uart.bin(INA[US1-j],1) 'Since GPIO1 is higher than GPIO5.
        uart.tx(TAB)
      uart.str(string(CR,LF))
      i++  
  elseif debug_gpiooption == GPIO_OUTPUT
    exit := 0
    j := 0
    DIRA[US1..US4]~~
    DIRA[GPIO1..GPIO5]~~
    OUTA[US1..US4] := FALSE
    OUTA[GPIO1..GPIO5] := FALSE
    repeat until i == 100000
      
      OUTA[US1..US4]  := TRUE
      OUTA[GPIO1..GPIO5] := TRUE
      uart.str(string("GPIO IS ON",CR,LF))
      waitcnt(clkfreq*30 + cnt)
      OUTA[US1..US4]  := FALSE
      OUTA[GPIO1..GPIO5] := FALSE
      uart.str(string("GPIO IS OFF",CR,LF))
      waitcnt(clkfreq*30 + cnt)
  
  climode    
pri debugmode(debugoption)| exit,i,j,tempstr,temp1
  waitcnt(clkfreq*2 + cnt)
   
  exit := 0

    case debugoption
      DEBUG_ALLIO:
        i := 0
         repeat until i == 100000
              {if i // 50 == 0 
                   uart.txflush(debug_port)
                   uart.str(string("P0P1P2P3P4P5P6P7P8P9P10"))
                   uart.str(string("P11P12P13P14P15P16P17P18P19P20"))
                   uart.str(string("P21P22P23P24P25P26P27P28P29P30")) 
                   uart.tx(CR)
                   uart.tx(LF)}
              'repeat j from 0 to 31
                   'uart.bin(outa[j],1)
              uart.bin(INA[0..31],32)      
              uart.tx(CR)
              uart.tx(LF)
              i++
      DEBUG_SERVO:
        DIRA[SERVO1..SERVO4]~~
        i := 0
        repeat i from 0 to 100000
          j := PWM_MIN_VALUE
          repeat j from PWM_MIN_VALUE to PWM_MAX_VALUE
            pwmout.Servo(SERVO1,j)
            pwmout.Servo(SERVO2,j)
            pwmout.Servo(SERVO3,j)
            pwmout.Servo(SERVO4,j)
            uart.str(string("PWM: "))
            uart.dec(j)
            uart.str(string("uS",CR,LF))
          repeat j from PWM_MAX_VALUE to PWM_MIN_VALUE
            pwmout.Servo(SERVO1,j)
            pwmout.Servo(SERVO2,j)
            pwmout.Servo(SERVO3,j)
            pwmout.Servo(SERVO4,j)
            uart.str(string("PWM: "))
            uart.dec(j)
            uart.str(string("uS",CR,LF))
        climode 
          
      DEBUG_UART:
        repeat
          i := 0
          repeat i from 0 to 127
            !outa[Error_LED]
            uart.str(string("$HELLO,WORLD"))
            uart.dec(i)
            uart.str(string("*",CR,LF))
            waitcnt(clkfreq/100 + cnt)
        
      DEBUG_ANALOG:
        i := 0
        repeat until i == 10000

          
          repeat i from 0 to 7
            uart.str(string("AN"))
            uart.dec(i+1)
            uart.str(string(": "))                     
            uart.dec(adc.in(i))
            uart.tx(TAB)
          uart.str(string(CR,LF))
        climode                                                
      DEBUG_SD:
        test_sdcard
        climode
      DEBUG_LED:
          DIRA[Startup_LED]~~
          DIRA[RunCLIMode_LED]~~
          DIRA[Armed_LED]~~
          DIRA[Error_LED]~~
          i := 0
          repeat i from 0 to 100
            !OUTA[Startup_LED]
            !OUTA[RunCLIMode_LED]
            !OUTA[Armed_LED]
            !OUTA[Error_LED]
            waitcnt(clkfreq/250 + cnt)
          init
  
PUB test_sdcard| r, sta, bytes 
  sdcard.opendir
   repeat while 0 == sdcard.nextfile(@tbuf)
      uart.str(@tbuf)
      uart.str(string(CR,LF)) 
   uart.str(string("That's the dir", CR,LF))
   sta := cnt
   r := sdcard.popen(string("speed2.txt"), "w")
   repeat 256
      sdcard.SDStr(string("TEST"))
   sdcard.pclose
   r := cnt - sta
   uart.str(string("Writing 2M took "))
   uart.dec(r)
   uart.str(string(CR,LF))
   sta := cnt
   r := sdcard.popen(string("speed.txt"), "r")
   repeat 256
      sdcard.pread(@bigbuf, 256)
   sdcard.pclose
   r := cnt - sta
   uart.str(string("Reading 2M took "))
   uart.dec(r)
   uart.str(string(CR,LF))

dat                   
  maintitle byte 13,10,"QuickStartPlus Main Menu",13,10,0
  main1 byte 32,32,"1) Debugging/Testing Mode Menu",13,10,0
  main2 byte 32,32,"2) Calibration Mode Menu",13,10,0
  main3 byte 32,32,"0) Exit",13,10,0
  mainAddr word @maintitle, @main1, @main2, @main3
  
  debugtitle byte 13,10,"Debug Menu",13,10,0 
  debug1 byte 32,32,"1) Servo Outputs",13,10,0
  debug2 byte 32,32,"2) UART",13,10,0
  debug3 byte 32,32,"3) Analog Inputs",13,10,0
  debug4 byte 32,32,"4) Not Used",13,10,0
  debug5 byte 32,32,"5) SD Card",13,10,0
  debug6 byte 32,32,"6) GPIO [US1..US4, GPIO1..GPIO5]",13,10,0
  debug7 byte 32,32,"7) LED",13,10,0
  debug8 byte 32,32,"8) All I/O [P0..P31]",13,10,0
  debug9 byte 32,32,"9) All Tests",13,10,0
  debug10 byte 32,32,"0) Exit",13,10,0
  debugAddr word @debugtitle, @debug1, @debug2, @debug3, @debug4, @debug5, @debug6, @debug7, @debug8, @debug9, @debug10

  calibtitle byte 13,10,"Calibration Menu",13,10,0
  calib1 byte 32,32,"1) Steering",13,10,0
  calib2 byte 32,32,"0) Exit",13,10,0
  calibAddr word @calibtitle, @calib1, @calib2

  gpiotitle byte 13,10,"GPIO Menu",13,10,0
  gpiotext1 byte 32,32,"1) Test As Inputs",13,10,0
  gpiotext2 byte 32,32,"2) Test As Outputs",13,10,0
  gpioAddr word @gpiotitle,@gpiotext1,@gpiotext2
  