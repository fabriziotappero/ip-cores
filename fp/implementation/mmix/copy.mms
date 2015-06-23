* SAMPLE PROGRAM: COPY A GIVEN FILE TO STANDARD OUTPUT

t        IS   $255
argc     IS   $0
argv     IS   $1
s        IS   $2
Buf_Size IS   5                 ridiculously small for testing
         LOC  Data_Segment
Buffer   LOC  @+Buf_Size
         GREG @
Arg0     OCTA 0,TextRead
Arg1     OCTA Buffer,Buf_Size
      
         LOC  #200              main(argc,argv) {
Main     CMP  t,argc,2          if (argc==2) goto openit
         PBZ  t,OpenIt
         GETA t,1F              fputs("Usage: ",stderr)
         TRAP 0,Fputs,StdErr
         LDOU t,argv,0          fputs(argv[0],stderr)
         TRAP 0,Fputs,StdErr
         GETA t,2F              fputs(" filename\n",stderr)
Quit     TRAP 0,Fputs,StdErr    
         NEG  t,0,1             quit: exit(-1)
         TRAP 0,Halt,0
1H       BYTE "Usage: ",0
         LOC  (@+3)&-4          align to tetrabyte
2H       BYTE " filename",#a,0

OpenIt   LDOU s,argv,8          openit: s=argv[1]
         STOU s,Arg0
         LDA  t,Arg0            fopen(argv[1],"r",file[3])
         TRAP 0,Fopen,3
         PBNN t,CopyIt          if (no error) goto copyit
         GETA t,1F              fputs("Can't open file ",stderr)
         TRAP 0,Fputs,StdErr
         SET  t,s               fputs(argv[1],stderr)
         TRAP 0,Fputs,StdErr
         GETA t,2F              fputs("!\n",stderr)
         JMP  Quit              goto quit
1H       BYTE "Can't open file ",0
         LOC  (@+3)&-4          align to tetrabyte
2H       BYTE "!",#a,0

CopyIt   LDA  t,Arg1            copyit:
         TRAP 0,Fread,3         items=fread(buffer,1,buf_size,file[3])
         BN   t,EndIt           if (items < buf_size) goto endit
         LDA  t,Arg1            items=fwrite(buffer,1,buf_size,stdout)
         TRAP 0,Fwrite,StdOut
         PBNN t,CopyIt          if (items >= buf_size) goto copyit
Trouble  GETA t,1F              trouble: fputs("Trouble w...!",stderr)
         JMP  Quit              goto quit
1H       BYTE "Trouble writing StdOut!",#a,0

EndIt    INCL t,Buf_Size
         BN   t,ReadErr         if (ferror(file[3])) goto readerr
         STO  t,Arg1+8
         LDA  t,Arg1            n=fwrite(buffer,1,items,stdout)
         TRAP 0,Fwrite,StdOut
         BN   t,Trouble         if (n < items) goto trouble
         TRAP 0,Halt,0          exit(0)
ReadErr  GETA t,1F              readerr: fputs("Trouble r...!",stderr)
         JMP  Quit              goto quit }
1H       BYTE "Trouble reading!",#a,0
