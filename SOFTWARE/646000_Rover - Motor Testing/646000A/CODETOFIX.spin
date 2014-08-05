PUB mainloop | i, j, value1, value2, value3,bootmode,ledmode,ledpin , tempstrA,tempstrB,tempstrC,storagecount,an1,an2,an3,an4,an5,an6,an7,an8,temp1, lasttime
  
  repeat' until strcomp(@rxbuffer,string("done"))

    
    
    'Read Sensors
     
    
      
    'getfcrxbuffer(@fcrxbuffer)
    'if uart.rxcheck(pc_port)
    getpcrxbuffer(@pcrxbuffer)
    'uart.str(debug_port,@pcrxbuffer)
    'uart.rxflush(debug_port)
    'uart.str(debug_port,@pcrxbuffer)
    'uart.str(debug_port,string(CR,LF))
    'uart.str(pc_port,@pcrxbuffer)
    'uart.tx(pc_port,CR)
    'uart.tx(pc_port,LF)

      
    case prioritylevel
   {   PRIORITY_LOW: 
    'Get latest command
      if util.strncomp(@pcrxbuffer,string("zzz"),0) ' CLI Mode,WORKS
        !outa[ledpin3]
        climode
      
      if util.strncomp(@pcrxbuffer,string("TIME"),5) ' Time Packet,WORKS
          hour := util.strntodec(util.strtok(@pcrxbuffer,2),0)
          minute := util.strntodec(util.strtok(@pcrxbuffer,3),0)
          sec := util.strntodec(util.strtok(@pcrxbuffer,4),0)
          msec := 0
          timer.set(hour,minute,sec)  'Reset Timer to match Time Signal
          'Testing - WORKS
          'uart.str(pc_port,string("GPS Time:"))
          'uart.dec(pc_port,gpstimestamp)          
      if util.strncomp(@pcrxbuffer,string("$SRV,"),0) 'Servo Packet,WORKS
        repeat i from 0 to 7
          'apm_servocmd[i] := util.strntodec(util.strtok(@pcrxbuffer,i+1),0)
           
         'Testing - WORKS
         'uart.str(pc_port,string("Servo:"))
         'repeat i from 0 to 7
         '  uart.dec(pc_port,servocmd[i])
         '  uart.tx(pc_port,SPACE)         
      if util.strncomp(@pcrxbuffer,string("$INF,"),0) 'Information Type, WORKS
       infopacket := util.strtok(@pcrxbuffer,1)

       'Testing - WORKS
       'uart.str(pc_port,string("Info:"))
       'uart.str(pc_port,infopacket)       
      if util.strncomp(@pcrxbuffer,string("$STA,"),0) 'Status Type, WORKS
      'if util.strncomp(@pcrxbuffer,string("ERR"),5) ' Error Packet, WORKS
       ' rcvderrorcode := util.strntodec(util.strtok(@pcrxbuffer,2),0)
        'Testing
        'uart.str(pc_port,string("Error Code:"))
        'uart.dec(pc_port,rcvderrorcode)
      if util.strncomp(@pcrxbuffer,string("QRY"),5) 'Status Query Packet, WORKS
        {repeat i from 1 to (curerrorcodeindex-1)
          uart.str(pc_port,string("$STA,ERR,"))          
          uart.dec(pc_port,curerrorcode[i])
          uart.tx(pc_port,CR)
          uart.tx(pc_port,LF)   }
      PRIORITY_HIGH:     
      if util.strncomp(@pcrxbuffer,string("$CON,"),0) 'Control Type, WORKS
      
        if util.strncomp(@pcrxbuffer,string("BOOT"),5) 'Boot Packet,WORKS
            bootmode := util.strntodec(util.strtok(@pcrxbuffer,2),0)
            case bootmode
              1: controlmode := CON_BOOT1
              2: controlmode := CON_BOOT2
              3: controlmode := CON_BOOT3
            'Testing
            'uart.str(pc_port,string("Boot Mode:"))
            'uart.dec(pc_port,bootmode)
        elseif util.strncomp(@pcrxbuffer,string("MODE"),5) ' MAVLink Mode
            temp1 := temp1 + 1
            'uart.str(debug_port,string(CR,LF))
            'uart.dec(debug_port,temp1)
            'uart.str(debug_port,string(CR,LF))
            controlmode :=  CON_MAVLINK_MODE
            mavlink_mode :=  util.strntodec(util.strtok(@pcrxbuffer,2),0)
            if mavlink_mode == MAV_MODE_PREFLIGHT
              uart.str(debug_port,string("MAV_STATE_BOOT"))
              uart.str(debug_port,string("I am rebooting now"))
              waitcnt(clkfreq/250 + cnt)
              REBOOT
        elseif util.strncomp(@pcrxbuffer,string("LANDVTOL"),5) 'Land Packet,WORKS
            controlmode := CON_LANDVTOL
            'Testing 
            'uart.str(pc_port,string("Landing:"))
        elseif util.strncomp(@pcrxbuffer,string("TAKEOFFVTOL"),5) 'Takeoff Packet,WORKS
            controlmode := CON_TAKEOFFVTOL
            'Testing 
            'uart.str(pc_port,string("Takeoff:"))
            'updateleds(0,ledpin4)
        elseif util.strncomp(@pcrxbuffer,string("HOVER"),5) 'Hover Packet,WORKS
            controlmode := CON_HOVER
            'Testing 
            'uart.str(pc_port,string("Hovering:"))
        elseif util.strncomp(@pcrxbuffer,string("CRUISE"),5) 'Cruise Packet,WORKS
            controlmode := pcrxbuffer
            'Testing 
            'uart.str(pc_port,string("cruising:"))
        elseif util.strncomp(@pcrxbuffer,string("RESET"),5) 'Reset Packet,WORKS
            controlmode := CON_RESET
            'Testing 
            'uart.str(pc_port,string("reset:"))
        elseif util.strncomp(@pcrxbuffer,string("OFF"),5) 'Off Packet,WORKS
            controlmode := CON_OFF
            'Testing 
            'uart.str(pc_port,string("off:"))
        elseif util.strncomp(@pcrxbuffer,string("MANUAL"),5) 'Manual Packet
            controlmode := CON_MANUAL
        else
          controlmode := -1 

          

        
    else
      droppedpacketcounter++
    
   
    
      
  

    
         
    
       ' Other Sensors
   
   { if VoltageSense <> -1
      batvoltage := adc.in(VoltageSense) * ADC_VOLTAGE_CONVERSION
      tempstrA := string("$STA,POWMV,")
      tempstrB := util.dec2str(batvoltage,@tempstr1)
      tempstrC := string("*",CR,LF)
      bytefill(@stringbuffer,0,100)
      bytemove(@stringbuffer,tempstrA,strsize(tempstrA))
      str.Concatenate(@stringbuffer,tempstrB)
      str.Concatenate(@stringbuffer,tempstrC)
      uart.str(pc_port,@stringbuffer)
      if LOG_EVERYTHING
        sd.pputs(@stringbuffer)
     
    if CurrentSense <> -1
      batcurrent := adc.in(CurrentSense) * ADC_CURRENT_CONVERSION
      tempstrA := string("$STA,POWMC,")
      tempstrB := util.dec2str(batcurrent,@tempstr1)
      tempstrC := string("*",CR,LF)
      bytefill(@stringbuffer,0,100)
      bytemove(@stringbuffer,tempstrA,strsize(tempstrA))
      str.Concatenate(@stringbuffer,tempstrB)
      str.Concatenate(@stringbuffer,tempstrC)
      uart.str(pc_port,@stringbuffer)
      if LOG_EVERYTHING
        sd.pputs(@stringbuffer)
      'datalog(@stringbuffer,storagecount++) }


 

  
  
  
  