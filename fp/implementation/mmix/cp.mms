% copy from StdIn to StdOut, no error checking
     LOC  Data_Segment
     GREG @
ArgR OCTA Buf,2  one char at a time
ArgW OCTA Buf,1  ditto
Buf  LOC  @+2

     LOC  #100
Main LDA  $255,ArgR
     TRAP 0,Fgets,StdIn
     BN   $255,Done
     LDA  $255,ArgW
     TRAP 0,Fwrite,StdOut
     JMP  Main
Done TRAP 0,0,Halt
