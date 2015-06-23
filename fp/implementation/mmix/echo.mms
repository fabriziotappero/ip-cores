argc    IS    $0
argv    IS    $1
        LOC   #100
Main    SUB   argc,argc,2
        PBNN  argc,2F
        JMP   9F
Blank   BYTE  ' ',0
1H      GETA  $255,Blank
        TRAP  0,Fputs,StdOut
        SUB   argc,argc,1
        ADD   argv,argv,8
2H      LDOU  $255,argv,8
        TRAP  0,Fputs,StdOut
        PBNZ  argc,1B
9H      GETA  $255,NewLine
        TRAP  0,Fputs,StdOut
        TRAP  0,Halt,0
NewLine BYTE #a,0

