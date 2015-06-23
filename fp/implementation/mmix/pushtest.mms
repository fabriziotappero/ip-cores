        LOC   #100
        GREG  @
String  BYTE  "n!",#a,0
Main    PUSHJ $5,1F
        ADD   $2,$5,#30
        STB   $2,String
        GETA  $255,String
        TRAP  0,Fputs,StdOut (the output should be 3!)
        TRAP  0,Halt,0
1H      SETL  $0,3
        POP   1,0
