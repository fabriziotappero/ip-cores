* Register stack test program by Hans-Peter Nilsson, January 2002
      LOC  #100
cnt   GREG
max   IS   17
msg   BYTE "No bug noticed here",#a,0

Main PUSHJ $16,Recurse
     GETA  $255,msg
     TRAP  0,Fputs,StdOut
     TRAP  0,Halt,0

Recurse ADDU cnt,cnt,1
        CMP  $0,cnt,max
        BZ   $0,0F
        GET  $1,rJ
        PUSHJ $16,Recurse
        PUT  rJ,$1
0H      POP  0,0
