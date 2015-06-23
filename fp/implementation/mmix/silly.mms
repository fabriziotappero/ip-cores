* A program that exercises all MMIX operations (more or less)
small       GREG   #abc
neg_zero    GREG   #8000000000000000
half        GREG   #3fe0000000000000
inf         GREG   #7ff0000000000000
sig_nan     GREG   #7ff1000000000000
round_off   GREG   ROUND_OFF<<16
round_up    GREG   ROUND_UP<<16
round_down  GREG   ROUND_DOWN<<16
addy        GREG   #7f6001b4c67bc809
addz        GREG   #ff5ffb6a4534a3f7
flip        GREG   #0102040810204080 
ry          GREG
rz          GREG
            LOC    Data_Segment
            GREG   @
Start_Inst  SUB    $4,half,$1
Final_Inst  SRU    $4,half,1
Load_Test   OCTA   #8081828384858687
            OCTA   #88898a8b8c8d8e8f
Jmp_Pop     JMP    @+8
            POP
Load_Begin  TETRA  #5f030405
Load_End    LDUNC  $3,$4,5
Big_Begin   GO     $40,ry,5
Big_End     ANDNL  $40,(ry-$0)<<8+5

            LOC    #100
Main        FCMP   $0,neg_zero,$5
            FCMP   $1,neg_zero,inf
            FCMP   $2,inf,sig_nan
            FUN    $3,sig_nan,sig_nan
            FEQL   $4,$4,neg_zero
            FADD   $5,half,inf
            FADD   $6,half,neg_zero
            FADD   $7,half,half
            FADD   $8,half,sig_nan
            FSUB   $9,half,small
            PUT    rA,round_off
            FSUB   $9,half,small
            FSUB   $9,small,half
            FSQRT  $10,$9
            FSUB   $11,sig_nan,$10
            PUT    rA,round_down
            FSUB   $12,half,half
            FSUB   $12,$20,$21
            FSUB   $12,$20,neg_zero
            PUT    rA,round_up
            SUB    $0,inf,1           % $0 = largest normal number
            FADD   $12,$0,small
            FIX    $12,half
            FIXU   $14,ROUND_DOWN,$9
            FLOT   $15,ROUND_DOWN,addy
            FLOT   $16,ROUND_UP,addy
            NEG    $1,1               % $1 = -1
            FLOT   $17,1
            FLOT   $17,$1
            FLOTU  $18,255
            FLOTU  $18,neg_zero
            FIX    $13,ROUND_NEAR,$18
            SFLOT  $18,ROUND_DOWN,addy
            SFLOT  $19,ROUND_UP,addy
            FSUB   $20,$18,$19
            FSUB   $20,$16,$15
            SFLOT  $20,1
            SFLOT  $20,$1
            SFLOTU $21,$1
            SFLOTU $21,255
            FMUL   $22,neg_zero,inf
            FMUL   $22,half,half
            FMUL   $23,small,$0
            PUT    rE,half
            FCMPE  $24,half,$21
            FCMPE  $24,neg_zero,small
            FCMPE  $24,neg_zero,half
            FCMPE  $24,half,inf
            FEQLE  $24,$15,$16
            PUT    rE,neg_zero
            FEQLE  $24,half,half
            FUNE   $24,half,half
            FSQRT  $25,ROUND_UP,$0
            FDIV   $26,$0,$25
            PUT    rA,$50
            FDIV   $26,$0,$25
            FMUL   $27,$25,$25
            FREM   $28,$9,half
            FREM   $29,$9,small
            FINT   $30,$9
            FINT   $30,ROUND_UP,small
            MUL    $31,flip,flip
            MUL    $32,flip,$1
            MUL    $33,flip,2
            DIV    $32,$32,$1
            DIV    $32,neg_zero,$1
            MULU   $32,flip,$1
            MULU   $31,flip,flip
            GET    $33,rH
            PUT    rD,$33
            DIV    $33,$1,3
            DIVU   $34,$31,flip
            ADD    $35,addy,addz
            FADD   $36,addy,addz
            CMP    $37,$36,$35
            GETA   $3,1F
            PUT    rW,$3
            LDT    $6,Start_Inst
            LDTU   $7,Final_Inst
1H          CMP    $5,$6,$7
            BNN    $5,1F
            INCML  $6,#100           % increase the opcode
            PUT    rX,$6             % ropcode 0
            RESUME                   % return to 1B
1H          BN     $0,@+4*6
            PBN    $0,@-4*1
            BNN    $0,@+4*6
            PBN    $0,@+4*5
            PBNN   $0,@+4*5
            BN     $0,@-4*3
            BNN    $0,@-4*3
            PBN    $0,@-4*3
            PBNN   $0,@-4*3
            BZ     $0,@+4*6
            PBZ    $0,@-4*1
            BNZ    $0,@+4*6
            PBZ    $0,@+4*5
            PBNZ   $0,@+4*5
            BZ     $0,@-4*3
            BNZ    $0,@-4*3
            PBZ    $0,@-4*3
            PBNZ   $0,@-4*3
            BP     $0,@+4*6
            PBP    $0,@-4*1
            BNP    $0,@+4*6
            PBP    $0,@+4*5
            PBNP   $0,@+4*5
            BP     $0,@-4*3
            BNP    $0,@-4*3
            PBP    $0,@-4*3
            PBNP   $0,@-4*3
            BOD    $0,@+4*6
            PBOD   $0,@-4*1
            BEV    $0,@+4*6
            PBOD   $0,@+4*5
            PBEV   $0,@+4*5
            BOD    $0,@-4*3
            BEV    $0,@-4*3
            PBOD   $0,@-4*3
            PBEV   $0,@-4*3
            LDA    $4,Load_Test+4
            GETA   $3,1F
            PUT    rW,$3
            LDTU   $7,Load_End
            LDTU   $6,Load_Begin
1H          CMPU   $8,$6,$7
            BNN    $8,1F
            INCML  $6,#100           % increase the opcode
            PUT    rX,$6
            RESUME                   % return to 1B
2H          OCTA   #fedcba9876543210 % becomes Jmp_Pop
            OCTA   #ffeeddccbbaa9988 % becomes Jmp_Pop
            NEG    ry,addy
            SET    rz,flip
            PUT    rM,addz
            POP
1H          GETA   $4,2B
            SETL   $7,4*11
            GO     $7,$7,$4
            GO     $7,$4,4*12
            PRELD  70,$4,$4
            PRELD  70,$4,0
            PREGO  70,$4,$4
            PREGO  70,$4,0
            CSWAP  $3,Load_Test+13
            GETA   $3,1F
            PUT    rW,$3
            SETL   rz,1
            ADD    ry,$4,4
            LDOU   $40,Jmp_Pop
            LDTU   $7,Big_End
            LDTU   $6,Big_Begin
1H          CMPU   $8,$6,$7
            BNN    $8,1F
            INCML  $6,#100           % increase the opcode
            PUT    rX,$6
            SET    $5,rz
            RESUME                   % return to 1B
1H          SL     $40,small,51
            SL     $40,small,52
            SAVE   $255,0
            PUT    rG,small-$0
            INCL   small-1,U_BIT<<8
            FADD   $100,small,$200
            PUT    rA,small-1        % enable underflow trip
            TRIP   1,$100,small
            FSUB   $100,small,$200   % cause underflow trip
            PUT    rL,10
            PUT    rL,small
            PUSHJ  11,@+4
            UNSAVE $255
            TRAP   0,Halt,0          % normal exit

            LOC    U_Handler
            PUSHJ  $255,Handler
3H          TRAP   0,$1
            SUB    $0,$1,1
            POP    2,0
4H          GET    $50,rX
            INCH   $50,#8100         % ropcode 1
            FLOT   $60,1
            PUT    rZ,$60
            JMP    2F

            LOC    0
            GET    $50,rX
            INCH   $50,#8200         % ropcode 2
            INCMH  $50,#ff00-(U_BIT<<8)
            TRAP   1
2H          PUT    rX,$50
            GET    $255,rB
            RESUME
Handler     SETL   $5,#abcd
            GET    $1,rJ
            PUSHJ  3,3B
            SUB    $10,$3,$4
            PUT    rJ,$1
            POP    11,(4B-3B)>>2

