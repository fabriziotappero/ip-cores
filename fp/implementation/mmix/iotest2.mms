* Additional IO test for the simulated simulator
* (Change "Chunk" to 8 in sim.mms to make the acid test!)

t IS $255
h IS 3

 LOC Data_Segment
*        initial value      final value
A OCTA #1111111111111111  #0011000011610a00
  OCTA #2222222222222222  #222222222262630a
  OCTA #3333333333333333  #0033333333646566
  OCTA #4444444444444444  #0a00444444313233
  OCTA #5555555555555555  #343536373839410a
  OCTA #6666666666666666  #0066666666313233
  OCTA #7777777777777777  #3435363738394142
  OCTA #8888888888888888  #00888888000a0000
  OCTA #9999999999999999  #999999990a0a000a
  OCTA #1111111111111111  #0000111178787979
  OCTA #2222222222222222  #000a000031313232
  OCTA #3333333333333333  #333334343535000a
  OCTA #4444444444444444  #0000444431313232
  OCTA #5555555555555555  #3333343435353636
  OCTA #6666666666666666  #0000666666707100
  OCTA #7777777777777777  #7777777777777777
  OCTA #8888888888888888  #8888888888888888
  OCTA #9999999999999999  #9999999999999999
 GREG @
 GREG @+256
Dat BYTE "xa",#a,"bc",#a,"def",#a,"123456789A",#a,"123456789AB"
    BYTE 0,#a,#a,#a,0,#a,"xxyy",0,#a,"1122334455",0,#a
    BYTE "112233445566pq",0,0
IOscr BYTE "ioscr.tmp",0
Arg0 OCTA IOscr,BinaryReadWrite
Arg1 OCTA A,0
Arg2 OCTA A,1
Arg3 OCTA A+3,1
Arg4 OCTA A+5,12
Arg5 OCTA A+13,12
Arg6 OCTA A+21,12
Arg7 OCTA A+29,12
Arg8 OCTA A+45,12
Arg9 OCTA A+61,7
Arg10 OCTA A+69,7
Arg11 OCTA A+77,7
Arg12 OCTA A+85,7
Arg13 OCTA A+101,7
Arg14 OCTA A+117,7
Arg15 OCTA A,8*18

 LOC #100
Main TRAP 0,Fclose,h
     LDA  t,Arg0
     TRAP 0,Fopen,h
     LDA  t,Dat
     TRAP 0,Fputws,h
     TRAP 0,Ftell,h
     SET  t,1000
     TRAP 0,Fseek,h
     TRAP 0,Ftell,h
     SET  t,1
     TRAP 0,Fseek,h
     TRAP 0,Ftell,h
     LDA  t,Arg1
     TRAP 0,Fgets,h
     LDA  t,Arg2
     TRAP 0,Fgets,h
     LDA  t,Arg3
     TRAP 0,Fgetws,h
     LDA  t,Arg4
     TRAP 0,Fgets,h
     LDA  t,Arg5
     TRAP 0,Fgets,h
     LDA  t,Arg6
     TRAP 0,Fgets,h
     LDA  t,Arg7
     TRAP 0,Fgets,h
     LDA  t,Arg8
     TRAP 0,Fgets,h
     LDA  t,Arg9
     TRAP 0,Fgetws,h
     LDA  t,Arg10
     TRAP 0,Fgetws,h
     LDA  t,Arg11
     TRAP 0,Fgetws,h
     LDA  t,Arg12
     TRAP 0,Fgetws,h
     LDA  t,Arg13
     TRAP 0,Fgetws,h
     NEG  t,3
     TRAP 0,Fseek,h
     TRAP 0,Ftell,h
     LDA  t,Arg14
     TRAP 0,Fgets,h
     SET  t,0
     TRAP 0,Fseek,h
     LDA  t,Arg15
     TRAP 0,Fwrite,h
     TRAP 0,Halt,0
