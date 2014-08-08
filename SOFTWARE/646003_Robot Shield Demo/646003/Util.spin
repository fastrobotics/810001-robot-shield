{{
  Object:       Util.spin
  Purpose:      This program contains some utility methods for use in other SPIN programs.
  Author:       Steve Warren, David Gitz, Chuck Rice
  Contents:
        strntofloat(str,n) : float
        strntodec(str,n) : integer
        strdeg2dec(str) - Converts a GPS Latitude or Longitude packet into Decimal Degrees.
        calcHaversineDistance - Written by Chuck Rice
}}
CON
  periodCON = 46
  commaCON =  44
  asterickCON = 42
  minuscon = 45

  c2pi = 2.0 * pi
  cEarthR = 6371.0   ' in km
obj
  fmath:        "DynamicMathLib.spin"
  
{pub strntofloat(str,n) : number | i, cbyte, fpt, fi
' converts str starting at n, ending at the first non numeric character to floating point
  i := n      
  fpt := false 
  repeat until ((cbyte := byte[str][i]) > 48 OR cbyte < 58 ) AND cbyte <> "." AND cbyte <> "#"
    if cbyte == "#"
      n := i++
      next
    elseif cbyte == "."
      fpt := true
      fi := i-n
    cbyte -= 48
    cbyte := fmath.FFloat(cbyte)
    if NOT fpt                                               
      number := fmath.FAdd(fmath.FMul(number,10.0),cbyte)
    else
      repeat i-fi
        cbyte := fmath.FMul(fmath.FFloat(cbyte),0.1)
      number := fmath.FAdd(number,cbyte)
    i++  }   
pub calc_currentmotor(x) : pwm |a,b
''MATLAB Computed Equation: (33*1000)./(x.^2);

  pwm := (200*500)/(x*x*x) 
pub calc_opposingmotor(x) : pwm
''MATLAB Computed Equations:
  pwm := -calc_currentmotor(x)
pub strntofloat(str,n) : number | i, cbyte, fpt, fi, ng
' converts str starting at n, ending at the first non numeric character to floating point
  i := n
  fpt := false
  ng := false
  repeat while ((cbyte := byte[str][i]) < "9" OR cbyte > "0" ) OR cbyte == "." OR cbyte == "-"
    if cbyte == "-"
      n := ++i
      ng := true
      next
    elseif cbyte == "."
      fpt := true
      fi := i-n
    cbyte -= 48
    cbyte := fmath.FFloat(cbyte)
    if NOT fpt                                               
      number := fmath.FAdd(fmath.FMul(number,10.0),cbyte)
    else
      repeat i-fi
        cbyte := fmath.FMul(cbyte,0.1)
      number := fmath.FAdd(number,cbyte)
    i++

  if ng
    fmath.FMul(number,-1.0)
    
pub strntodec(str,n) : number | i,j, cbyte
' converts str starting at n, ending at the first non numeric character to decimal
  i := n
  j := strsize(str)
  number := 0                                                                   
  repeat until ((cbyte := byte[str][i]) > "9" OR cbyte < "0" OR i > j ) ''AND cbyte <> ","
    if cbyte == ","
      i++
      next
    cbyte -= "0"                 
    number := number*10 + cbyte 
    i++     
    
pub strncomp(str1,str2,n) : tf | k,c
' checks str1 starting at n to see if a substring str2 exists there

  c := strsize(str2)
  k := 0
  
  repeat c
    if byte[str1][n+k] <> byte[str2][k]
      return false
    k++ 
  return true
   
pub strbytefind(str1,sbyte,n) : i
' searches str1 starting at index n for the character sbtye

  i := n
  
  repeat until i>(strsize(str1)-1)
    if byte[str1][i] == sbyte
      return i 
    i++
pub strdeg2float(str1)|outdegrees,outminutes,i,j,pow,perindex,minusflag  
'Converts gps lat/long packets into degrees, in decimal:
'Ex:  GPS lat:  4807.038, where 48 is the degrees and 07.038 is the minutes.
'Result should be 48.1173 degrees.
'Find the period in the packet
  perindex := strbytefind(str1,periodCON,0)
  'comuart.dec(perindex)
'Calculate the Degrees in the Packet
 j:= 0
 outdegrees := 0
 outminutes := 0
 pow := 0
 minusflag := 0
  if byte[str1][0] == minuscon
     minusflag := 1 
  repeat i from minusflag to (perindex - 2) 
    if i == (perindex - 2)
      quit
    pow := perindex - 3 - j
    case pow
      0:outdegrees += (byte[str1][i] - 48)* 1
      1:outdegrees += (byte[str1][i] - 48)* 10
      2:outdegrees += (byte[str1][i] - 48)* 100
    j++
  j:= 0

  if minusflag
    outdegrees := fmath.fdiv(outdegrees,10.0)

'Calculate Minutes  
  repeat i from (perindex - 2) to 10

     case j
      0:outminutes += (byte[str1][i] - 48)* 10000
      1:outminutes += (byte[str1][i] - 48)* 1000
      2:
      3:outminutes += (byte[str1][i] - 48)* 100
      4:outminutes += (byte[str1][i] - 48)* 10
      5:outminutes += (byte[str1][i] - 48)* 1
      6:quit
     j++
  outminutes := fmath.ffloat(outminutes)
  outminutes := fmath.fdiv(outminutes,1000.0)
  outminutes := fmath.fdiv(outminutes,60.0)
  outdegrees := fmath.ffloat(outdegrees)
  outdegrees := fmath.fadd(outdegrees,outminutes)

  if minusflag
    outdegrees := fmath.fneg(outdegrees)
  return outdegrees

pub calcHaversineDistance(lat1,lon1,lat2,lon2) | deltaLat,deltaLon,t1,t2,tsq1,tsq2,a,c,d,t3


  lat1 := fmath.Radians(lat1)
  lat2 := fmath.Radians(lat2)
  lon1 := fmath.Radians(lon1)
  lon2 := fmath.Radians(lon2)
  
  deltaLat := fmath.fsub(lat2,lat1)
  deltaLon := fmath.fsub(lon2,lon1)

  t1   := fmath.Fsin(fmath.fdiv(deltaLat,2.0))
  t2   := fmath.Fsin(fmath.fdiv(deltaLon,2.0))
  tsq1 := fmath.fmul(t1,t1)
  tsq2 := fmath.fmul(t2,t2)
  t3   := fmath.fmul(fmath.fmul(fmath.fcos(Lat1),fmath.fcos(lat2)),tsq2)
  a    := fmath.fadd(tsq1,t3)
 
  t1   := fmath.fsqr(a)
  t2   := fmath.fsqr(fmath.fsub(1.0,a))
  t3   := fmath.fatan2(t1,t2)
  c    := fmath.fmul(2.0,t3)
  d    := fmath.fmul(cEarthR,c) ' result in kilometers

  return fmath.fmul(d,0.621371192) ' Convert kilometers to StatMiles  
pub calculateBearing(lat1,lon1,lat2,lon2) | bearing,t1,t2,t3,t4,t5,dlon

  {lat1 := fmath.Radians(lat1)
  lat2 := fmath.Radians(lat2)
  lon1 := fmath.Radians(lon1)
  lon2 := fmath.Radians(lon2)}
'' lat1,lon1,lat2,lon2,distance are floating point variables in radians
'' Returns bearing in floating point degrees
   
   
   dlon := fmath.fsub(lon2,lon1)

   
   t1 := fmath.fmul(fmath.fsin(dlon),fmath.fcos(lat2))
   t2 := fmath.fmul(fmath.fcos(lat1),fmath.fsin(lat2))
   t3 := fmath.fmul(fmath.fsin(lat1),fmath.fmul(fmath.fcos(lat2),fmath.fcos(dlon)))

   t4 := fmath.fsub(t2,t3)
   t5 := fmath.FAtan2(t1,t4)

  if (fmath.fcmp(t5,0.0) < 0)
    bearing := fmath.fadd(t5,c2pi)
  else
    bearing := fmath.fsub(c2pi , t4)

  return fmath.Degrees(bearing)

pub strtok(message, field) | fieldptr, i,j,messagelen,tokenmsg,flag
''6-APR-09
''DPG:  Inputs is a whole string and what field you want out of it, 0-indexed.  String shoudl start with a "$"
''      and end with a "*" (although not required).
  fieldptr := 0
  i := 0
  j := 0
  messagelen := strsize(message)
  'Look for "$" Start Character
  repeat while (i < messagelen) 
    if byte[message][i] == "$"
      i++
      quit
    if i == messagelen
      return -1
    i++
  flag := 0
  repeat until flag OR (i > messagelen)  
    if fieldptr == field
      if ((byte[message][i] == commacon) OR (byte[message][i] == asterickcon)) 'Repeat until another "," or "*"
        flag := 1
      else
        byte[tokenmsg][j] := byte[message][i]
        j++
    if byte[message][i] == commacon
      fieldptr += 1
    i++

  byte[tokenmsg][j] := 0 '0 Delimit String for strcomp and other string purposes
  return tokenmsg
pub dec2str(value, pntr) | div, x, p
''   Author..... Jon "JonnyMac" McPhalen (aka Jon Williams)
''               Copyright (c) 2011 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... jon@jonmcphalen.term

'' Convert a decimal value to a string at pntr

  p := pntr                                                     ' save address of string

  x := (value == negx)                                          

  if (value < 0)                                                ' if negative
    value := ||(value + x)                                      '  make positive
    byte[pntr++] := "-"                                         '  put sign in string

  div := 1_000_000_000                                          ' initial divisor

  repeat 10                                                     ' convert to string
    if (value => div)                                           ' if not leading 0
      byte[pntr++] := (value / div + "0" + x * (div == 1))      '  print character 
      value //= div                                             '  remove digit from value
      result~~                                                  '  set print "0" flag
    elseif result or (div == 1)
      byte[pntr++] := "0"
    div /= 10                                                   ' update divisor

  byte[pntr] := 0                                               ' terminate string

  return p                                                      ' return address for string methods