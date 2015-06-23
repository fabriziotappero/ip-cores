* TESTING I/O (besides what was tested by the copy program)
* (intended for online test)

at       IS   $255
Buf      IS   Data_Segment+2
         LOC  Buf+9*2
Arg0     OCTA Buf,9
Arg1     OCTA Filename,BinaryReadWrite
         LOC  @+1
Filename BYTE "iotest.tmp",0
         GREG Buf
      
         LOC  #200
Main     LDA  at,Arg0
         TRAP 0,Fgets,StdIn     Fgets(StdIn,Buf,9)
         LDA  at,Buf
         TRAP 0,Fputs,StdOut    Fputs(StdOut,Buf)
         LDA  at,Arg0
         TRAP 0,Fgetws,StdIn    Fgetws(StdIn,Buf,9)
         LDA  at,Buf
         TRAP 0,Fputws,StdOut   Fputws(StdOut,Buf)
         TRAP 0,Fclose,StdIn    Fclose(StdIn)
         TRAP 0,Fclose,StdIn    Fclose(StdIn)
         LDA  at,Arg1
         TRAP 0,Fopen,StdIn     Fopen(StdIn,"iotest.tmp",BinaryReadWrite)
         NEG  at,1
         TRAP 0,Fseek,StdIn     Fseek(StdIn,-1)
         TRAP 0,Ftell,StdIn     Ftell(StdIn)
         LDA  at,Buf
         TRAP 0,Fputws,StdIn    Fputws(StdIn,Buf)
         SET  at,2
         TRAP 0,Fseek,StdIn     Fseek(StdIn,2)
         LDA  at,Arg0
         TRAP 0,Fgets,StdIn     Fgets(StdIn,Buf,9)
         TRAP 0,Halt,0

