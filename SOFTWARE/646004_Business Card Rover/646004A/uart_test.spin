' Requires remote XBee in loopback mode (DIN connected to DOUT)

OBJ

  PC  :  "FullDuplexSerial"
  XB  :  "FullDuplexSerial"

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
   
  ' Set pins and Baud rate for XBee communication
  XB_Rx = 7                 ' XBee DOUT   Data coming in from XBee     
  XB_Tx = 8                 ' XBee DIN    Data going out of XBee
  XB_Baud = 9600
  ' Set pins and baud rate for PC communication
  PC_Rx = 31
  PC_Tx = 30
  PC_Baud = 9600

VAR

  long stack[50]             ' Stack space for second cog

Pub Go

  PC.start(PC_Rx, PC_Tx, %0000, PC_Baud) ' Initialize comms for PC
  XB.start(XB_Rx, XB_Tx, %0010, XB_Baud) ' Initialize comms for XBee
  'cognew(XB_to_PC,@stack)            ' Start cog for XBee--> PC comms
  PC.rxFlush                         ' Empty buffer for data from PC
  repeat
    XB.str(string("hello"))
    'XB.str(string("hello"))
                ' Accept data from PC and send to XBee

Pub XB_to_PC

  XB.rxFlush                    ' Empty buffer for data from XB
  repeat
    PC.tx(XB.rx)                ' Accept data from XBee, send to PC