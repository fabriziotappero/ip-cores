* Traffic Signal Problem
rate GREG 100 % ridiculously small, for testing (shd be 250MHz)
t IS $255
Sensor_Buf IS Data_Segment
     GREG Sensor_Buf

       LOC #100
Lights  IS 3
Sensor IS 4
%Lights_Name BYTE "/dev/lights",0
%Sensor_Name BYTE "/dev/sensor",0
Lights_Name BYTE "lights",0     (temporary name)
Sensor_Name BYTE "sensor",0    (temporary name)
Lights_Args OCTA Lights_Name,BinaryWrite
Sensor_Args OCTA Sensor_Name,BinaryRead
Read_Sensor OCTA Sensor_Buf,1
Boulevard BYTE #77,0 DelMar green, WALK; Berkly red, DONT
          BYTE #7f,0 DelMar green, DONT; Berkly red, DONT
          BYTE #73,0 DelMar green, off;  Berkly red, DONT
          BYTE #bf,0 DelMar amber, DONT; Berkly red, DONT
Avenue    BYTE #dd,0 DelMar red, DONT; Berkly green, WALK
          BYTE #df,0 DelMar red, DONT; Berkly green, DONT
          BYTE #dc,0 DelMar red, DONT; Berkly green, off
          BYTE #ef,0 DelMar red, DONT; Berkly amber, DONT

goal GREG  % transition time for lights
Main GETA t,Lights_Args
     TRAP 0,Fopen,Lights
     GETA t,Sensor_Args
     TRAP 0,Fopen,Sensor
     GET  goal,rC
     ANDNMH goal,#ffff   % temporary patch
     JMP  2F

      GREG @
delay_go GREG
Delay GET t,rC
     ANDNMH t,#ffff   % temporary patch
      SUBU t,t,goal  NB: not CMPU
      PBN  t,Delay
      GO  delay_go,delay_go,0

flash_go GREG
n     GREG
green GREG
temp  GREG
Flash SET  n,8
1H    ADD  t,green,2*1
      TRAP 0,Fputs,Lights DONT WALK
      ADD  temp,goal,rate
      SR   t,rate,1
      ADDU goal,goal,t
      GO   delay_go,Delay
      ADD  t,green,2*2
      TRAP 0,Fputs,Lights off
      SET  goal,temp
      GO   delay_go,Delay
      SUB   n,n,1
      PBP   n,1B
      ADD  t,green,2*1
      TRAP 0,Fputs,Lights DONT WALK
      MUL  t,rate,4
      ADDU goal,goal,t
      GO   delay_go,Delay
      ADD  t,green,2*3
      TRAP 0,Fputs,Lights DONT WALK, amber
      GO   flash_go,flash_go,0

Wait  GET  goal,rC
     ANDNMH goal,#ffff   % temporary patch
1H    GETA t,Read_Sensor
      TRAP 0,Fread,Sensor
      LDB  t,Sensor_Buf
      BZ   t,Wait
      GETA green,Boulevard
      GO   flash_go,Flash
      MUL   t,rate,8
      ADDU  goal,goal,t
      GO   delay_go,Delay
      GETA  t,Avenue
      TRAP  0,Fputs,Lights
      MUL    t,rate,8
      ADDU  goal,goal,t
      GO   delay_go,Delay
      GETA  green,Avenue
      GO   flash_go,Flash
      GETA  t,Read_Sensor
      TRAP  0,Fread,Sensor % clear redundant signal
      MUL   t,rate,5
      ADDU  goal,goal,t
      GO   delay_go,Delay
2H    GETA  t,Boulevard
      TRAP  0,Fputs,Lights
      MUL   t,rate,18
      ADDU  goal,goal,t
      GO   delay_go,Delay
      JMP   1B     
